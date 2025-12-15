import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Add this
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/models.dart';
import '../../core/utils/ui_utils.dart';
import '../../widgets/animated_gradient_bg.dart';

class AddReportScreen extends StatefulWidget {
  final String reportType; // 'LOST' or 'FOUND'

  const AddReportScreen({super.key, required this.reportType});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  XFile? _imageFile; // Changed to XFile
  String _selectedCategory = 'Electronics'; // Default selection

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Electronics', 'icon': Icons.devices},
    {'title': 'Water Bottle', 'icon': Icons.water_drop},
    {'title': 'Accessory', 'icon': Icons.watch},
    {'title': 'Key', 'icon': Icons.vpn_key},
    {'title': 'Wallet', 'icon': Icons.account_balance_wallet},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile; // Directly assign XFile
        });
      }
    } catch (e) {
      UiUtils.showModernSnackBar(context, 'Error picking image: $e', isSuccess: false);
    }
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      UiUtils.showModernSnackBar(context, 'Please fill in required fields', isSuccess: false);
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      UiUtils.showModernSnackBar(context, 'You must be logged in to post', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = '';
      if (_imageFile != null) {
        // Pass XFile directly to uploadImage. The StorageService should handle XFile.
        // If StorageService.uploadImage expects a dart:io File, it would need to be
        // converted: `File(_imageFile!.path)` for non-web, or bytes for web.
        // Assuming StorageService is updated to handle XFile or its path/bytes.
        imageUrl = await _storageService.uploadImage(_imageFile!, 'items');
      }

      final newItem = ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        imageUrl: imageUrl, 
        type: widget.reportType,
        category: _selectedCategory,
        date: DateTime.now(),
      );

      await _firestoreService.createPost(newItem);

      if (mounted) {
        UiUtils.showModernSnackBar(context, 'Report Posted Successfully!');
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
    final isLost = widget.reportType == 'LOST';
    final themeColor = isLost ? AppColors.errorRed : AppColors.primaryBlue;
    final titleText = isLost ? 'Report Lost Item' : 'Report Found Item';

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          const AnimatedGradientBg(),
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          titleText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Dummy button to balance the back button and center the text
                      Opacity(
                        opacity: 0.0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                          onPressed: null,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Item Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Item Name
                        _buildLabel('Item Name', isRequired: true),
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'e.g. Backpack, Phone Charger, Keys',
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildLabel('Description'),
                        _buildTextField(
                          controller: _descriptionController,
                          hintText: 'e.g. White-colored 90W charger with 2 metres Type-C cable',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Type/Category
                        _buildLabel('Type/Category', isRequired: true),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category['title'];
                              return _buildCategoryCard(
                                title: category['title'],
                                icon: category['icon'],
                                isSelected: isSelected,
                                activeColor: themeColor,
                                onTap: () => setState(() => _selectedCategory = category['title']),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        _buildLabel('Location', isRequired: true),
                        _buildTextField(
                          controller: _locationController,
                          hintText: isLost 
                              ? 'e.g. Last seen at Library, Canteen...' 
                              : 'e.g. Found at Room C-106...',
                        ),
                        const SizedBox(height: 16),

                        // Image Picker
                        _buildLabel('Image'),
                        _buildImagePicker(),

                        const SizedBox(height: 40),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
  
  // NOTE: Need to update _buildCategoryCard to accept color or refresh entire file if too complex for partial
  // Since _buildCategoryCard uses AppColors.primaryBlue hardcoded, we should pass the color to it.


  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Slight transparency for gradient
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Fixed width for square-ish look
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : const Color(0xFF4A5568),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E0)), 
        ),
        child: _imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Use Image.network for web compatibility since XFile.path on web is a blob URL
              child: kIsWeb 
                  ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                  : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Add Image',
                  style: TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                   width: 48,
                   height: 48,
                   decoration: BoxDecoration(
                     border: Border.all(color: const Color(0xFFCBD5E0), width: 2, style: BorderStyle.solid), 
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Icon(Icons.add, color: Color(0xFF718096)),
                ),
              ],
          ),
      ),
    );
  }
}
