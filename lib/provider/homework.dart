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

  /// 🟢 Upload file to Private Storage
  Future<bool> updateHomework({
    required String id,
    required String title,
    required String description,
    required String? materialLink,
  }) async {
    try {
      debugPrint('🟡 Updating homework with ID: $id');

      // Prepare update data
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
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';

      // Use UUID directly in file path
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
      final signedUrl = await supabase.storage
          .from('homework')
          .createSignedUrl(filePath, 60 * 60); // 1 hour expiry

      return signedUrl;
    } catch (e) {
      debugPrint('❌ Error generating signed URL: $e');
      return null;
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
