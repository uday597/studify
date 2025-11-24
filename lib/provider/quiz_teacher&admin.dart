import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<dynamic> _quizzes = [];
  List<dynamic> _questions = [];
  bool _loading = false;

  List<dynamic> get quizzes => _quizzes;
  List<dynamic> get questions => _questions;
  bool get loading => _loading;

  // Get all quizzes for admin/teacher
  Future<void> getQuizzes({String? batchId}) async {
    try {
      _loading = true;
      notifyListeners();

      var query = _supabase.from('quizzes').select('*, batches(name)');

      if (batchId != null) {
        query = query.eq('batch_id', batchId);
      }

      final response = await query.order('created_at', ascending: false);
      _quizzes = response;

      _loading = false;
      notifyListeners();
    } catch (error) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create new quiz

  Future<PostgrestMap> createQuiz({
    required String title,
    required String batchId,
    String? description,
    String? subject,
    int? durationMinutes,
    String? createdBy,
    int? adminId,
  }) async {
    try {
      final insertData = {
        'title': title,
        'description': description,
        'subject': subject,
        'duration_minutes': durationMinutes,
        'batch_id': batchId,
        'admin_id': adminId,
        'total_marks': 0,
        'is_published': false,
      };

      if (createdBy != null) {
        insertData['created_by'] = createdBy;
      }

      final response = await _supabase
          .from('quizzes')
          .insert(insertData)
          .select()
          .single();

      _quizzes.insert(0, response);
      notifyListeners();
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateQuiz({
    required String quizId,
    String? title,
    String? description,
    String? subject,
    int? durationMinutes,
    bool? isPublished,
  }) async {
    try {
      final updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (subject != null) updateData['subject'] = subject;
      if (durationMinutes != null)
        updateData['duration_minutes'] = durationMinutes;
      if (isPublished != null) updateData['is_published'] = isPublished;

      final response = await _supabase
          .from('quizzes')
          .update(updateData)
          .eq('id', quizId)
          .select()
          .single();

      // Update in local list
      final index = _quizzes.indexWhere((q) => q['id'] == quizId);
      if (index != -1) {
        _quizzes[index] = response;
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Delete quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _supabase.from('quizzes').delete().eq('id', quizId);

      _quizzes.removeWhere((q) => q['id'] == quizId);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Add question to quiz
  Future<void> addQuestion({
    required String quizId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    int marks = 1,
  }) async {
    try {
      final response = await _supabase
          .from('questions')
          .insert({
            'quiz_id': quizId,
            'question_text': questionText,
            'option_a': optionA,
            'option_b': optionB,
            'option_c': optionC,
            'option_d': optionD,
            'correct_answer': correctAnswer,
            'explanation': explanation,
            'marks': marks,
          })
          .select()
          .single();

      _questions.add(response);

      // Update total marks in quiz
      await _updateQuizTotalMarks(quizId);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Get questions for a quiz
  Future<void> getQuestions(String quizId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*')
          .eq('quiz_id', quizId)
          .order('created_at');

      _questions = response;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Update question
  Future<void> updateQuestion({
    required String questionId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
    int? marks,
  }) async {
    try {
      final updateData = {};
      if (questionText != null) updateData['question_text'] = questionText;
      if (optionA != null) updateData['option_a'] = optionA;
      if (optionB != null) updateData['option_b'] = optionB;
      if (optionC != null) updateData['option_c'] = optionC;
      if (optionD != null) updateData['option_d'] = optionD;
      if (correctAnswer != null) updateData['correct_answer'] = correctAnswer;
      if (explanation != null) updateData['explanation'] = explanation;
      if (marks != null) updateData['marks'] = marks;

      await _supabase.from('questions').update(updateData).eq('id', questionId);

      // Refresh questions list
      final quizId = _questions.firstWhere(
        (q) => q['id'] == questionId,
      )['quiz_id'];
      await getQuestions(quizId);
    } catch (error) {
      rethrow;
    }
  }

  // Delete question
  Future<void> deleteQuestion(String questionId) async {
    try {
      final question = _questions.firstWhere((q) => q['id'] == questionId);
      final quizId = question['quiz_id'];

      await _supabase.from('questions').delete().eq('id', questionId);

      _questions.removeWhere((q) => q['id'] == questionId);

      // Update total marks
      await _updateQuizTotalMarks(quizId);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Helper function to update quiz total marks
  Future<void> _updateQuizTotalMarks(String quizId) async {
    try {
      final totalMarksResponse = await _supabase
          .from('questions')
          .select('marks')
          .eq('quiz_id', quizId);

      final totalMarks = totalMarksResponse.fold<int>(
        0,
        (sum, question) => sum + (question['marks'] as int),
      );

      await _supabase
          .from('quizzes')
          .update({'total_marks': totalMarks})
          .eq('id', quizId);
    } catch (error) {
      rethrow;
    }
  }
}
