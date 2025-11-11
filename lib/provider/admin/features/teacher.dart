import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class TeacherProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> get teachers => _teachers;

  Future<void> fatchTeachers({required int adminId}) async {
    try {
      final List<dynamic> data = await supabase
          .from('teachers')
          .select()
          .eq('admin_id', adminId);
      _teachers = data.map((e) => e as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Error fetching teachers: $e');
    }
  }

  Future<void> addTeacher({
    required String name,
    required String email,
    required String gender,
    required String mobile,
    required String address,
    required String salary,
    required String password,
    required int adminId,
  }) async {
    try {
      await supabase.from('teachers').insert({
        'name': name,
        'salary': salary,
        'gender': gender,
        'mobile': mobile,
        'address': address,
        'email': email,
        'password': password,
        'admin_id': adminId,
      });
      await fatchTeachers(adminId: adminId);
    } catch (e) {
      throw Exception('Error adding teacher:$e');
    }
  }

  Future<void> updateTeacher({
    required String id,
    required String name,
    required String email,
    required String salary,
    required String gender,
    required String mobile,
    required String address,
    required String password,
    required int adminId,
  }) async {
    try {
      await supabase
          .from('teachers')
          .update({
            'name': name,
            'email': email,
            'salary': salary,
            'gender': gender,
            'mobile': mobile,
            'address': address,
            'password': password,
          })
          .eq('id', id)
          .eq('admin_id', adminId);
      await fatchTeachers(adminId: adminId);
    } catch (e) {
      throw Exception('Error updating teacher: $e');
    }
  }

  Future<void> deleteTeacher(String id, int adminId) async {
    try {
      await supabase
          .from('teachers')
          .delete()
          .eq('id', id)
          .eq('admin_id', adminId);
      await fatchTeachers(adminId: adminId);
    } catch (e) {
      throw Exception('Error deleting teacher: $e');
    }
  }
}
