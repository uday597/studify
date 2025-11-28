import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class LeaveManagerProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _leaveRequests = [];
  List<Map<String, dynamic>> get leaveRequests => _leaveRequests;

  // Fetch All Leaves (Admin)
  Future<void> fetchLeaves(int adminId) async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('admin_id', adminId)
        .order('created_at', ascending: false);

    _leaveRequests = List<Map<String, dynamic>>.from(res);

    notifyListeners();
  }

  // Add Leave
  Future<void> addLeave({
    required String userId,
    required String role,
    required String reason,
    required DateTime fromDate,
    required DateTime toDate,
    required int adminId,
  }) async {
    final res = await supabase.from('leave_requests').insert({
      'user_id': userId,
      'role': role,
      'reason': reason,
      'from_date': fromDate.toString().split(' ')[0],
      'to_date': toDate.toString().split(' ')[0],
      'status': 'pending',
      'admin_id': adminId,
    });

    print("INSERT RESULT ===> $res");
  }

  Future<void> fetchLeavesRole(int adminId, {String? userId}) async {
    var query = supabase
        .from('leave_requests')
        .select()
        .eq('admin_id', adminId);

    if (userId != null) {
      query = query.eq('user_id', userId); // Filter for student only
    }

    final res = await query.order('created_at', ascending: false);
    _leaveRequests = List<Map<String, dynamic>>.from(res);
    notifyListeners();
  }

  // Update Status (Admin)
  Future<void> updateStatus({
    required String leaveId,
    String? newStatus,
    String? reply,
  }) async {
    await supabase
        .from('leave_requests')
        .update({'status': newStatus, 'admin_reply': reply})
        .eq('id', leaveId);

    final index = _leaveRequests.indexWhere((e) => e['id'] == leaveId);
    if (index != -1) {
      _leaveRequests[index]['status'] = newStatus;
    }

    notifyListeners();
  }

  // Delete Leave
  Future<void> deleteLeave(String leaveId) async {
    await supabase.from('leave_requests').delete().eq('id', leaveId);

    _leaveRequests.removeWhere((e) => e['id'] == leaveId);
    notifyListeners();
  }
}
