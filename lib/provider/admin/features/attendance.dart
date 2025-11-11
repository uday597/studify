import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class AttendanceProvider extends ChangeNotifier {
  bool loading = false;
  List<Map<String, dynamic>> _teacherAttendance = [];
  List<Map<String, dynamic>> _studentAttendance = [];

  Future<void> markTeacherAttendance({
    required String teacherId,
    required String status,
    required int adminId,
  }) async {
    try {
      loading = true;
      notifyListeners();

      final date = DateTime.now().toIso8601String().split('T')[0];

      // Check if attendance already exists
      final existingRecord = await supabase
          .from('teacher_attendance')
          .select()
          .eq('teacher_id', teacherId)
          .eq('date', date)
          .eq('admin_id', adminId)
          .maybeSingle();

      if (existingRecord != null) {
        // UPDATE existing record
        await supabase
            .from('teacher_attendance')
            .update({
              'status': status,
              'created_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingRecord['id']);
        debugPrint('✅ UPDATED attendance for teacher: $teacherId');
      } else {
        // INSERT new record
        await supabase.from('teacher_attendance').insert({
          'teacher_id': teacherId,
          'status': status,
          'marked_by': adminId,
          'admin_id': adminId,
          'date': date,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ CREATED new attendance for teacher: $teacherId');
      }
    } catch (e, st) {
      debugPrint('❌ Error saving teacher attendance: $e\n$st');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markStudentAttendance({
    required String studentId,
    required String batchId,
    required String status,
    required int adminId,
  }) async {
    try {
      loading = true;
      notifyListeners();

      final date = DateTime.now().toIso8601String().split('T')[0];

      // Check if attendance already exists
      final existingRecord = await supabase
          .from('student_attendance')
          .select()
          .eq('student_id', studentId)
          .eq('date', date)
          .eq('admin_id', adminId)
          .maybeSingle();

      if (existingRecord != null) {
        // UPDATE existing record
        await supabase
            .from('student_attendance')
            .update({
              'status': status,
              'batch_id': batchId,
              'created_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingRecord['id']);
        debugPrint('✅ UPDATED attendance for student: $studentId');
      } else {
        // INSERT new record
        await supabase.from('student_attendance').insert({
          'student_id': studentId,
          'batch_id': batchId,
          'status': status,
          'marked_by': adminId,
          'admin_id': adminId,
          'date': date,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ CREATED new attendance for student: $studentId');
      }
    } catch (e, st) {
      debugPrint('❌ Error saving student attendance: $e\n$st');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Rest of your methods remain same...
  Future<List<Map<String, dynamic>>> getTeacherAttendance({
    required int adminId,
    DateTime? date,
  }) async {
    try {
      var query = supabase
          .from('teacher_attendance')
          .select('*, teachers(name, email)')
          .eq('admin_id', adminId);

      if (date != null) {
        final dateString = date.toIso8601String().split('T')[0];
        query = query.eq('date', dateString);
      }

      final data = await query.order('created_at', ascending: false);
      _teacherAttendance = data.cast<Map<String, dynamic>>();
      notifyListeners();
      return _teacherAttendance;
    } catch (e) {
      throw Exception('Error fetching teacher attendance: $e');
    }
  }

  // 🟢 Get student attendance history
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory({
    required String studentId,
    required int adminId,
  }) async {
    try {
      final data = await supabase
          .from('student_attendance')
          .select('*, batches(name)')
          .eq('student_id', studentId)
          .eq('admin_id', adminId)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching student attendance history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance({
    required int adminId,
    DateTime? date,
    String? batchId,
  }) async {
    try {
      var query = supabase
          .from('student_attendance')
          .select('*, students(name, email), batches(name)')
          .eq('admin_id', adminId);

      if (date != null) {
        final dateString = date.toIso8601String().split('T')[0];
        query = query.eq('date', dateString);
      }

      if (batchId != null) {
        query = query.eq('batch_id', batchId);
      }

      final data = await query.order('created_at', ascending: false);
      _studentAttendance = data.cast<Map<String, dynamic>>();
      notifyListeners();
      return _studentAttendance;
    } catch (e) {
      throw Exception('Error fetching student attendance: $e');
    }
  }
}
