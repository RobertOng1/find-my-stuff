import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/animated_gradient_bg.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/models.dart';
import '../../core/utils/ui_utils.dart';

class ProofFormScreen extends StatefulWidget {
  final ItemModel item;

  const ProofFormScreen({super.key, required this.item});

  @override
  State<ProofFormScreen> createState() => _ProofFormScreenState();
}

class _ProofFormScreenState extends State<ProofFormScreen> {
  final _proofDescriptionController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _proofDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    if (_proofDescriptionController.text.isEmpty) {
      UiUtils.showModernSnackBar(context, 'Please describe the item features', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newClaim = ClaimModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: widget.item.id,
        claimantId: 'current_user_id', // Replace with AuthService
        finderId: widget.item.userId,
        claimantName: 'Current User', // Replace with AuthService
        claimantAvatar: '',
        status: 'PENDING',
        proofDescription: _proofDescriptionController.text,
        proofImages: [], // Add image logic later
        timestamp: DateTime.now(),
      );

      await _firestoreService.submitClaim(newClaim);

      if (mounted) {
        UiUtils.showModernSnackBar(context, 'Proof submitted successfully!');
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
        title: const Text(
          'Proof Form',
          style: TextStyle(
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
                        const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: const Text(
                            'Please provide accurate details about the item to verify your ownership. This helps us ensure items are returned to their rightful owners.',
                            style: TextStyle(
                              color: AppColors.textDark, // Darker for readability
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Item Name *'),
                  _buildGlassTextField(hintText: widget.item.title, readOnly: true),
                  
                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Where did you lose it? *'),
                  _buildGlassTextField(hintText: widget.item.location, readOnly: true),
                  
                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Date Lost *'),
                  _buildGlassTextField(hintText: '11/21/2025'), // Date Picker logic needed
                  
                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Distinguishing Features *'),
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
                        hintText: 'Navy blue with red zipper pulls. Has a small tear on the bottom left pocket...',
                        hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.7), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  CustomButton(
                    text: _isLoading ? 'Submitting...' : 'Submit Claim',
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
