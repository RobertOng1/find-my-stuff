import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';

/// Service for uploading images to Cloudinary.
/// 
/// Uses unsigned upload preset for secure mobile uploads without
/// exposing API secrets.
class StorageService {
  /// Uploads an image to Cloudinary and returns the secure URL.
  /// 
  /// [file] - The XFile from image_picker
  /// [folderName] - The folder to organize images in (e.g., 'items', 'claims')
  /// 
  /// Returns the secure HTTPS URL of the uploaded image.
  /// Throws an exception if upload fails.
  Future<String> uploadImage(XFile file, String folderName) async {
    try {
      // Read file as bytes
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Create the request
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add the upload preset (required for unsigned uploads)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      // Add folder for organization
      request.fields['folder'] = folderName;
      
      // Add the file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final secureUrl = jsonResponse['secure_url'] as String;
        return secureUrl;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception('Cloudinary upload failed: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
