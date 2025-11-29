import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BehaviorProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> records = [];
  bool isLoading = false;

  //  INSERT new behavior record
  Future<void> addBehavior({
    required String studentId,
    required String batchId,
    required int adminId,
    required int classBehavior,
    required int games,
    required int homework,
    required int discipline,
    required int communication,
    String? remarks,
  }) async {
    await supabase.from('behavior_records').upsert({
      'student_id': studentId,
      'batch_id': batchId,
      'admin_id': adminId,
      'class_behavior': classBehavior,
      'games': games,
      'homework': homework,
      'discipline': discipline,
      'communication': communication,
      'remarks': remarks,
    }, onConflict: 'student_id');
  }

  //  Fetch latest record for a student
  Future<void> fetchLatest(String studentId) async {
    isLoading = true;
    notifyListeners();

    final response = await supabase
        .from('behavior_records')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(1);

    records = List<Map<String, dynamic>>.from(response);

    isLoading = false;
    notifyListeners();
  }

  //  FETCH full history
  Future<void> fetchHistory(String studentId) async {
    isLoading = true;
    notifyListeners();

    final response = await supabase
        .from('behavior_records')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    records = List<Map<String, dynamic>>.from(response);

    isLoading = false;
    notifyListeners();
  }

  //  UPDATE existing record
  Future<void> updateBehavior({
    required String id,
    required int classBehavior,
    required int games,
    required int homework,
    required int discipline,
    required int communication,
    String? remarks,
  }) async {
    await supabase
        .from('behavior_records')
        .update({
          'class_behavior': classBehavior,
          'games': games,
          'homework': homework,
          'discipline': discipline,
          'communication': communication,
          'remarks': remarks,
        })
        .eq('id', id);
  }

  //  DELETE a record
  Future<void> deleteBehavior(String id) async {
    await supabase.from('behavior_records').delete().eq('id', id);
  }
}
