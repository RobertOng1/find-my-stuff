import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const String _prefix = 'form_draft_';

  // Save draft data
  static Future<void> saveDraft(String formId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$formId';
    await prefs.setString(key, jsonEncode(data));
  }

  // Get draft data
  static Future<Map<String, dynamic>?> getDraft(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$formId';
    final dataString = prefs.getString(key);
    
    if (dataString != null) {
      try {
        return jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding draft: $e');
        return null;
      }
    }
    return null;
  }

  // Clear draft data
  static Future<void> clearDraft(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$formId';
    await prefs.remove(key);
  }
}
