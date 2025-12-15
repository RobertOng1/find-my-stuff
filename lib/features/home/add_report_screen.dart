import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/services/firestore_service.dart';
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
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      UiUtils.showModernSnackBar(context, 'Please fill in required fields', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newItem = ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
        userId: 'current_user_id', // Replace with AuthService().currentUser?.uid
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        imageUrl: '', // Placeholder for now
        type: widget.reportType,
        category: _categoryController.text.isNotEmpty ? _categoryController.text : 'General',
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
    final title = isLost ? 'Report Lost Item' : 'Report Found Item';
    final color = isLost ? AppColors.errorRed : AppColors.successGreen;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                  // Placeholder for Image Upload
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.primaryBlue.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Add Photos',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Item Name'),
                  _buildGlassTextField(hintText: 'e.g. Blue Backpack', controller: _titleController),
                  
                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Category'),
                  _buildGlassTextField(hintText: 'Select Category', controller: _categoryController),

                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Location'),
                  _buildGlassTextField(hintText: 'Where was it lost/found?', controller: _locationController),

                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Date & Time'),
                  _buildGlassTextField(hintText: 'Select Date & Time'), // Date Picker logic needed later

                  const SizedBox(height: 16),
                  
                  _buildSectionLabel('Description'),
                  _buildGlassTextField(
                    hintText: 'Describe the item...',
                    maxLines: 4,
                    controller: _descriptionController,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: color.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Post Report',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hintText,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Container(
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
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
