import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBDEFB)),
              ),
              child: const Text(
                'Please provide accurate details about the item to verify your ownership. This helps us ensure items are returned to their rightful owners.',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Item Name *', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            CustomTextField(hintText: widget.item.title), // Read-only or pre-filled
            
            const SizedBox(height: 16),
            const Text('Where did you lose it? *', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            CustomTextField(hintText: widget.item.location),
            
            const SizedBox(height: 16),
            const Text('Date Lost *', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            const CustomTextField(hintText: '11/21/2025'), // Should be date picker
            
            const SizedBox(height: 16),
            const Text('Distinguishing Features *', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _proofDescriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Navy blue with red zipper pulls. Has a small tear on the bottom left pocket...',
                  hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
                  border: InputBorder.none,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft Saved')),
                  );
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
    );
  }
}
