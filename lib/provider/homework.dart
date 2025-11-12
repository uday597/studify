import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studify/main.dart';
import 'package:uuid/uuid.dart';

class HomeworkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> get homeworkList => _homeworkList;

  Future<void> fetchHomeworkByBatch(String batchId, int adminId) async {
    final data = await supabase
        .from('homework')
        .select('*')
        .eq('batch_id', batchId)
        .eq('admin_id', adminId)
        .order('created_at', ascending: false);

    _homeworkList = data.map((e) => e as Map<String, dynamic>).toList();
    notifyListeners();
  }

  /// 🟢 Upload file to Private Storage
  Future<String?> uploadMaterial(File file, String teacherId) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final filePath = '$teacherId/$fileName';

      // Upload to private bucket
      await supabase.storage.from('homework').upload(filePath, file);

      debugPrint('✅ File uploaded to private storage: $filePath');

      // Return just the file path, we'll generate signed URL when needed
      return filePath;
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      return null;
    }
  }

  /// 🟢 Get Signed URL for private files
  Future<String?> getSignedUrl(String filePath) async {
    try {
      // Generate signed URL valid for 1 hour
      final signedUrl = await supabase.storage
          .from('homework')
          .createSignedUrl(filePath, 60 * 60); // 1 hour expiry

      return signedUrl;
    } catch (e) {
      debugPrint('❌ Error generating signed URL: $e');
      return null;
    }
  }

  /// 🟢 Add new homework
  Future<void> addHomework({
    required String title,
    required String description,
    required String? materialLink, // This is now filePath, not public URL
    required String batchId,
    required String teacherId,
    required int adminId,
  }) async {
    await supabase.from('homework').insert({
      'title': title,
      'description': description,
      'material_link': materialLink, // Store filePath, not URL
      'batch_id': batchId,
      'teacher_id': teacherId,
      'admin_id': adminId,
    });
    await fetchHomeworkByBatch(batchId, adminId);
  }
}
