import 'dart:ui';
import 'dart:io'; // Added for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Added for Image Picker
import '../../widgets/animated_gradient_bg.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart'; // Added Storage Service
import '../../core/models/models.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/image_picker_helper.dart'; // Added Helper

class ProofFormScreen extends StatefulWidget {
  final ItemModel item;
  final bool isFoundReport;

  const ProofFormScreen({
    super.key, 
    required this.item,
    this.isFoundReport = false,
  });

  @override
  State<ProofFormScreen> createState() => _ProofFormScreenState();
}

class _ProofFormScreenState extends State<ProofFormScreen> {
  final _proofDescriptionController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService(); // Init Storage Service

  File? _selectedImage; // State for selected image
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerHelper.pickImage(context, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _proofDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    // Validation Logic
    if (widget.isFoundReport) {
      // For Found Report: Image is MANDATORY, Description is Optional
      if (_selectedImage == null) {
        UiUtils.showModernSnackBar(context, 'Please attach a photo of the item', isSuccess: false);
        return;
      }
    } else {
      // For Claim: Description is Mandatory (as per original logic), Image is Optional (but recommended)
      if (_proofDescriptionController.text.isEmpty) {
        UiUtils.showModernSnackBar(context, 'Please describe the item features', isSuccess: false);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService(); // Need auth service to get current user
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Upload Image if selected
      List<String> proofImages = [];
      if (_selectedImage != null) {
        final imageUrl = await _storageService.uploadImage(
          XFile(_selectedImage!.path),
          'claims',
        );
        proofImages.add(imageUrl);
      }

      final newClaim = ClaimModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: widget.item.id,
        claimantId: currentUser.uid,
        finderId: widget.item.userId,
        claimantName: currentUser.displayName ?? 'Unknown',
        claimantAvatar: currentUser.photoURL ?? '',
        status: 'PENDING',
        proofDescription: _proofDescriptionController.text,
        proofImages: proofImages,
        timestamp: DateTime.now(),
      );

      await _firestoreService.submitClaim(newClaim);

      // Notification is handled by Firestore listener in MainScreen (foreground)
      // For background notifications, deploy Cloud Functions in `functions/` folder

      if (mounted) {
        UiUtils.showModernSnackBar(context, widget.isFoundReport ? 'Report submitted successfully!' : 'Proof submitted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showModernSnackBar(context, 'Error: $e', isSuccess: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFoundReport ? 'Safe Handover' : 'Proof Form';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const AnimatedGradientBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Info Box (Glass)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.volunteer_activism, color: AppColors.primaryBlue, size: 24), // Volunteer/Handover icon
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.isFoundReport
                              ? 'Terima kasih orang baik! 😇 Tolong kirim 1 foto barang yang kamu temukan agar Owner yakin barangnya aman.'
                              : 'Please provide accurate details about the item to verify your ownership.',
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Item Name'),
                  _buildGlassTextField(hintText: widget.item.title, readOnly: true),
                  
                  const SizedBox(height: 16),
                  
                  // ONLY show Location/Date for CLAIM mode (when I lost something and claiming a found item)
                  // Hide for FOUND REPORT mode (when I found something and reporting to owner)
                  if (!widget.isFoundReport) ...[
                      _buildSectionLabel('Where did you lose it? *'),
                      _buildGlassTextField(hintText: widget.item.location, readOnly: true),
                      
                      const SizedBox(height: 16),
                      
                      _buildSectionLabel('Date Lost *'),
                      _buildGlassTextField(hintText: '11/21/2025'),
                      
                      const SizedBox(height: 16),
                  ],

                  _buildSectionLabel(widget.isFoundReport ? 'Message to Owner (Optional)' : 'Distinguishing Features *'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _proofDescriptionController,
                      maxLines: 4,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: widget.isFoundReport 
                            ? 'Hai, barangnya aman di saya. Bisa ketemuan di...' 
                            : 'Navy blue with red zipper pulls. Has a small tear on the bottom left pocket...',
                        hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.7), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),

                  // TODO: Add Image Picker Here (Currently placeholder in logic but UI needs it)
                  // For now, we assume logic exists or will be added. 
                  // Adding a placeholder UI for Image Picker as it was missing in previous view/edit
                  const SizedBox(height: 24),
                  _buildSectionLabel(widget.isFoundReport ? 'Photo Evidence (Required) *' : 'Images'),
                   GestureDetector( // Changed to GestureDetector for interaction
                    onTap: _pickImage,
                    child: Container(
                      height: 150, // Slightly taller
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), style: BorderStyle.solid),
                        image: _selectedImage != null 
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                   Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue, size: 32),
                                   SizedBox(height: 8),
                                   Text('Tap to add photo', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500))
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                          ),
                    ),
                   ),
                  
                  const SizedBox(height: 32),
                  
                  CustomButton(
                    text: _isLoading ? 'Submitting...' : (widget.isFoundReport ? 'Notify Owner' : 'Submit Claim'),
                    onPressed: _isLoading ? () {} : _submitClaim,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        UiUtils.showModernSnackBar(context, 'Draft Saved');
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Save Draft',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12, 
          color: AppColors.textGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hintText, 
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: readOnly,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: readOnly ? AppColors.textGrey : AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: readOnly ? AppColors.textDark : AppColors.textGrey.withOpacity(0.7)
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
