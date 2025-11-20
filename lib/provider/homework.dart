import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studify/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HomeworkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> get homeworkList => _homeworkList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchHomeworkByBatch(String batchId, int adminId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await supabase
          .from('homework')
          .select('*, teacher:teacher_id (name)')
          .eq('batch_id', batchId)
          .eq('admin_id', adminId)
          .order('created_at', ascending: false);

      _homeworkList = List<Map<String, dynamic>>.from(
        data.map((hw) {
          return {...hw, 'teacher_name': hw['teacher']?['name'] ?? 'Unknown'};
        }),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('❌ Error fetching homework with teacher: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateHomework({
    required String id,
    required String title,
    required String description,
    required String? materialLink,
  }) async {
    try {
      debugPrint('🟡 Updating homework with ID: $id');

      final updateData = {
        'title': title,
        'description': description,
        'material_link': materialLink,
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('🟡 Update data: $updateData');

      final response = await supabase
          .from('homework')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ Updated homework response: $response');

      // Update local list
      final index = _homeworkList.indexWhere((hw) => hw['id'].toString() == id);
      if (index != -1) {
        _homeworkList[index] = {
          ..._homeworkList[index],
          'title': title,
          'description': description,
          'material_link': materialLink,
          'updated_at': DateTime.now().toIso8601String(),
        };
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error updating homework: $e');
      if (e is PostgrestException) {
        debugPrint('❌ Postgrest Error: ${e.message}');
        debugPrint('❌ Postgrest Details: ${e.details}');
      }
      return false;
    }
  }

  Future<String?> uploadMaterial(File file, String teacherId) async {
    if (teacherId.isEmpty) {
      debugPrint('❌ Teacher ID is empty. Cannot upload file.');
      return null;
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';

      final filePath = '$teacherId/$fileName';

      await supabase.storage.from('homework').upload(filePath, file);

      debugPrint('✅ File uploaded to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      return null;
    }
  }

  Future<String?> getSignedUrl(String filePath) async {
    try {
      debugPrint('🟡 Generating signed URL for: $filePath');

      // ✅ Check if filePath is valid
      if (filePath.isEmpty) {
        debugPrint('❌ filePath is empty');
        return null;
      }

      // ✅ Check if file exists in storage
      try {
        final fileExists = await supabase.storage
            .from('homework')
            .list(path: filePath.split('/').first); // folder check

        debugPrint('📁 Folder contents: $fileExists');
      } catch (e) {
        debugPrint('⚠️ Error checking file existence: $e');
      }

      // ✅ Generate signed URL
      final signedUrl = await supabase.storage
          .from('homework')
          .createSignedUrl(filePath, 60 * 60); // 1 hour

      debugPrint('✅ Signed URL generated successfully: $signedUrl');
      return signedUrl;
    } catch (e) {
      debugPrint('❌ Error generating signed URL: $e');

      // ✅ Detailed error logging
      if (e is StorageException) {
        debugPrint('❌ Storage Error: ${e.message}');
        debugPrint('❌ Storage Status: ${e.statusCode}');
      }

      // ✅ Alternative: Try to get public URL
      try {
        final publicUrl = supabase.storage
            .from('homework')
            .getPublicUrl(filePath);

        debugPrint('🔗 Public URL: $publicUrl');
        return publicUrl;
      } catch (e2) {
        debugPrint('❌ Public URL also failed: $e2');
      }

      return null;
    }
  }

  Future<String?> getPublicUrl(String filePath) async {
    try {
      debugPrint('🟡 Getting public URL for: $filePath');

      if (filePath.isEmpty) {
        debugPrint('❌ filePath is empty');
        return null;
      }

      final publicUrl = supabase.storage
          .from('homework')
          .getPublicUrl(filePath);

      debugPrint('✅ Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error getting public URL: $e');
      return null;
    }
  }

  Future<bool> deleteHomework(
    String id,
    String? materialLink,
    String batchId,
    int adminId,
  ) async {
    try {
      debugPrint("🗑 Deleting homework with ID: $id");
      debugPrint("🗑 Material link to delete: $materialLink");

      // Delete attached file first (not required if null)
      if (materialLink != null && materialLink.isNotEmpty) {
        debugPrint("🗑 Attempting to delete file from storage: $materialLink");
        final deleteResult = await supabase.storage.from('homework').remove([
          materialLink,
        ]);
        debugPrint("🗑 File removal result: $deleteResult");
      } else {
        debugPrint("🗑 No material link to delete");
      }

      // Delete row from database
      debugPrint("🗑 Deleting database record with ID: $id");
      final deleteResponse = await supabase
          .from('homework')
          .delete()
          .eq('id', id);
      debugPrint("🗑 Database delete response: $deleteResponse");

      // Refresh list
      await fetchHomeworkByBatch(batchId, adminId);
      debugPrint("✅ Homework deleted successfully");

      return true;
    } catch (e) {
      debugPrint("❌ Error deleting homework: $e");
      if (e is PostgrestException) {
        debugPrint("❌ Postgrest Error: ${e.message}");
        debugPrint("❌ Postgrest Details: ${e.details}");
      }
      return false;
    }
  }

  Future<bool> addHomework({
    required String title,
    required String description,
    required String? materialLink,
    required String batchId,
    required String teacherId,
    required int adminId,
  }) async {
    try {
      await supabase.from('homework').insert({
        'title': title,
        'description': description,
        'material_link': materialLink,
        'batch_id': batchId,
        'teacher_id': teacherId,
        'admin_id': adminId,
      });

      // Refresh the list
      await fetchHomeworkByBatch(batchId, adminId);
      return true;
    } catch (e) {
      debugPrint('❌ Error adding homework: $e');
      return false;
    }
  }
}
