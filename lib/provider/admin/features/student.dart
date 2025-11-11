import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class StudentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _StudentList = [];
  List<Map<String, dynamic>> get StudentList => _StudentList;
  void clearData() {
    _StudentList = [];
    notifyListeners();
    print('🔄 StudentProvider data cleared');
  }

  Future<void> fatchStudentdata({required int adminId}) async {
    try {
      final List<dynamic> data = await supabase
          .from('students')
          .select()
          .eq('admin_id', adminId);
      _StudentList = data.map((e) => e as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

  Future<void> fetchStudentsByBatch(String batchId, int adminId) async {
    try {
      final data = await supabase
          .from('students')
          .select('*, batches(name)')
          .eq('batch_id', batchId)
          .eq('admin_id', adminId);
      _StudentList = data.map((e) => e as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Error fetching students for batch: $e');
    }
  }

  Future<void> addStudentdata({
    required String name,
    required String email,
    required String father,
    required String gender,
    required String mobile,
    required String address,
    required String batchId,
    required String password,
    required int adminId,
  }) async {
    try {
      await supabase.from('students').insert({
        'name': name,
        'father': father,
        'gender': gender,
        'mobile': mobile,
        'address': address,
        'batch_id': batchId,
        'password': password,
        'admin_id': adminId,
      });
      await fetchStudentsByBatch(batchId, adminId);
    } catch (e) {
      throw Exception('Error adding student:$e');
    }
  }

  Future<void> updateStudentdata({
    required String id,
    required String name,
    required String email,
    required String father,
    required String gender,
    required String mobile,
    required String address,
    required String password,
    required String batchId,
    required int adminId,
  }) async {
    try {
      await supabase
          .from('students')
          .update({
            'name': name,
            'email': email,
            'father': father,
            'gender': gender,
            'mobile': mobile,
            'address': address,
            'batch_id': batchId,
            'password': password,
          })
          .eq('id', id)
          .eq('admin_id', adminId);
      await fetchStudentsByBatch(batchId, adminId);
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  Future<void> deleteStudent(String id, String batchId, int adminId) async {
    try {
      await supabase
          .from('students')
          .delete()
          .eq('id', id)
          .eq('admin_id', adminId);
      await fetchStudentsByBatch(batchId, adminId);
    } catch (e) {
      throw Exception('Error deleting student: $e');
    }
  }
}
