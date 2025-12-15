import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(XFile file, String folderName) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('$folderName/$fileName');
      
      final Uint8List data = await file.readAsBytes();
      final UploadTask uploadTask = ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
