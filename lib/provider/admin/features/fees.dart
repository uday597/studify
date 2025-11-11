import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class FeesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _feesList = [];
  List<Map<String, dynamic>> get feesList => _feesList;

  bool _loading = false;
  bool get loading => _loading;

  // 🟢 Fetch all fees for admin
  Future<void> fetchFees({required int adminId}) async {
    try {
      _loading = true;
      notifyListeners();

      final data = await supabase
          .from('student_fees')
          .select('*, students(name, email), batches(name)')
          .eq('admin_id', adminId)
          .order('submission_date', ascending: false)
          .order('submission_time', ascending: false);

      _feesList = data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching fees: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 🟢 Add new fee
  Future<void> addFee({
    required String studentId,
    required String batchId,
    required double amount,
    required int adminId,
  }) async {
    try {
      await supabase.from('student_fees').insert({
        'student_id': studentId,
        'batch_id': batchId,
        'admin_id': adminId,
        'amount': amount,
        'status': 'Pending',
        'submission_date': DateTime.now().toIso8601String().split('T')[0],
        'submission_time': DateTime.now()
            .toIso8601String()
            .split('T')[1]
            .substring(0, 8),
      });

      await fetchFees(adminId: adminId);
    } catch (e) {
      throw Exception('Error adding fee: $e');
    }
  }

  // 🟢 Update fee (ALL columns)
  Future<void> updateFee({
    required String feeId,
    required int adminId,
    required String status,
    required double amount,
  }) async {
    try {
      await supabase
          .from('student_fees')
          .update({
            'status': status,
            'amount': amount,
            'submission_date': DateTime.now().toIso8601String().split('T')[0],
            'submission_time': DateTime.now()
                .toIso8601String()
                .split('T')[1]
                .substring(0, 8),
          })
          .eq('id', feeId)
          .eq('admin_id', adminId);

      await fetchFees(adminId: adminId);
    } catch (e) {
      throw Exception('Error updating fee: $e');
    }
  }

  // 🟢 Delete fee
  Future<void> deleteFee(String feeId, int adminId) async {
    try {
      await supabase
          .from('student_fees')
          .delete()
          .eq('id', feeId)
          .eq('admin_id', adminId);

      await fetchFees(adminId: adminId);
    } catch (e) {
      throw Exception('Error deleting fee: $e');
    }
  }

  // 🟢 Get fee history for specific student
  Future<List<Map<String, dynamic>>> getStudentFeeHistory({
    required String studentId,
    required int adminId,
  }) async {
    try {
      final data = await supabase
          .from('student_fees')
          .select('*')
          .eq('student_id', studentId)
          .eq('admin_id', adminId)
          .order('submission_date', ascending: false)
          .order('submission_time', ascending: false);

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching student fee history: $e');
    }
  }

  // 🟢 Get student fees (NEW METHOD)
  Future<List<Map<String, dynamic>>> getStudentFees({
    required String studentId,
    required int adminId,
  }) async {
    try {
      final data = await supabase
          .from('student_fees')
          .select('*')
          .eq('student_id', studentId)
          .eq('admin_id', adminId)
          .order('submission_date', ascending: false)
          .order('submission_time', ascending: false);

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching student fees: $e');
    }
  }

  // 🟢 Clear fees data
  void clearFees() {
    _feesList = [];
    notifyListeners();
  }
}
