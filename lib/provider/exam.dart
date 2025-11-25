import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class ExamsProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> get exams => _exams;

  // Add Exam
  // exams_provider.dart
  Future<bool> addExam(Map<String, dynamic> examData) async {
    try {
      _loading = true;
      notifyListeners();

      print('📝 Adding exam with data: $examData');

      final response = await supabase.from('exams').insert(examData).select();

      print('✅ Exam added successfully: $response');

      if (response.isNotEmpty) {
        _exams.add(response.first);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding exam: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  } // ✅ Fetch Exams by Batch

  Future<void> fetchExamsByBatch(String batchId) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await supabase
          .from('exams')
          .select('*')
          .eq('batch_id', batchId)
          .order('exam_date', ascending: true);

      _exams = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching exams: $e');
      _exams = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Update Exam
  Future<bool> updateExam(String examId, Map<String, dynamic> examData) async {
    try {
      _loading = true;
      notifyListeners();

      await supabase.from('exams').update(examData).eq('id', examId);

      final index = _exams.indexWhere((exam) => exam['id'] == examId);
      if (index != -1) {
        _exams[index] = {..._exams[index], ...examData};
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Delete Exam
  Future<bool> deleteExam(String examId) async {
    try {
      _loading = true;
      notifyListeners();

      await supabase.from('exams').delete().eq('id', examId);

      _exams.removeWhere((exam) => exam['id'] == examId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
