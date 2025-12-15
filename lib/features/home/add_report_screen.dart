import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/models.dart';
import '../../core/utils/ui_utils.dart';


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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Add Photos',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(hintText: 'e.g. Blue Backpack', controller: _titleController),
              
              const SizedBox(height: 16),
              
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(hintText: 'Select Category', controller: _categoryController),

              const SizedBox(height: 16),
              
              const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(hintText: 'Where was it lost/found?', controller: _locationController),

              const SizedBox(height: 16),
              
              const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const CustomTextField(hintText: 'Select Date & Time'), // Date Picker logic needed later

              const SizedBox(height: 16),
              
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(hintText: 'Describe the item...', maxLines: 4, controller: _descriptionController),

              const SizedBox(height: 32),

              CustomButton(
                text: _isLoading ? 'Posting...' : 'Post Report',
                onPressed: _isLoading ? () {} : _submitReport,
                backgroundColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
