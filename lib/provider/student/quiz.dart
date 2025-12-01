import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentQuizProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<dynamic> _availableQuizzes = [];
  List<dynamic> _attemptedQuizzes = [];
  List<dynamic> _quizQuestions = [];
  dynamic _currentAttempt;
  bool _loading = false;
  Map<String, String> _selectedAnswers = {};
  bool _quizSubmitted = false;
  Map<String, dynamic> _quizResults = {};

  List<dynamic> get availableQuizzes => _availableQuizzes;
  List<dynamic> get attemptedQuizzes => _attemptedQuizzes;
  List<dynamic> get quizQuestions => _quizQuestions;
  dynamic get currentAttempt => _currentAttempt;
  bool get loading => _loading;
  Map<String, String> get selectedAnswers => _selectedAnswers;
  bool get quizSubmitted => _quizSubmitted;
  Map<String, dynamic> get quizResults => _quizResults;

  Future<String?> getStudentBatchId(String studentId) async {
    try {
      final studentData = await _supabase
          .from('students')
          .select('batch_id')
          .eq('id', studentId)
          .single();

      return studentData['batch_id'];
    } catch (error) {
      return null;
    }
  }

  Future<void> getAvailableQuizzes(String studentId) async {
    try {
      _loading = true;
      notifyListeners();

      final studentBatchId = await getStudentBatchId(studentId);
      if (studentBatchId == null) {
        throw Exception('Student batch not found');
      }

      final response = await _supabase
          .from('quizzes')
          .select('*, batches(name)')
          .eq('batch_id', studentBatchId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      _availableQuizzes = response.where((quiz) {
        return quiz['id'] != null &&
            quiz['title'] != null &&
            quiz['batches'] != null;
      }).toList();

      _loading = false;
      notifyListeners();
    } catch (error) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  } // Get attempted quizzes by student

  Future<void> getAttemptedQuizzes(String studentId) async {
    try {
      final response = await _supabase
          .from('student_quiz_attempts')
          .select('*, quizzes(*, batches(name))')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      _attemptedQuizzes = response;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateQuizReport(String studentId) async {
    try {
      // STEP 1: Fetch all attempts
      final attempts = await _supabase
          .from('student_quiz_attempts')
          .select('*, quizzes(title), batches(name)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      if (attempts.isEmpty) {
        return {
          'attempts': [],
          'summary': {
            'total_quizzes': 0,
            'average_percentage': 0,
            'accuracy': 0,
            'total_correct': 0,
            'total_wrong': 0,
          },
        };
      }

      int totalCorrect = 0;
      int totalWrong = 0;
      double totalPercentage = 0;

      List<Map<String, dynamic>> quizReports = [];

      for (var attempt in attempts) {
        final totalQuestions = (attempt['total_questions'] as num).toInt();
        final correct = (attempt['correct_answers'] as num).toInt();
        final wrong = (attempt['wrong_answers'] as num).toInt();
        final totalMarks =
            (attempt['total_marks_obtained'] as num?)?.toInt() ?? 0;

        final percentage = totalQuestions > 0
            ? (correct / totalQuestions) * 100
            : 0;

        totalCorrect += correct;
        totalWrong += wrong;
        totalPercentage += percentage;

        quizReports.add({
          'quiz_title': attempt['quizzes']['title'],
          'batch': attempt['batches']['name'],
          'date': attempt['submitted_at'],
          'total_questions': totalQuestions,
          'correct_answers': correct,
          'wrong_answers': wrong,
          'percentage': percentage.toStringAsFixed(1),
          'total_marks_obtained': totalMarks,
        });
      }

      // STEP 3: Overall summary
      final avgPercentage = totalPercentage / attempts.length;
      final accuracy = (totalCorrect + totalWrong) > 0
          ? (totalCorrect / (totalCorrect + totalWrong)) * 100
          : 0;

      final summary = {
        'total_quizzes': attempts.length,
        'average_percentage': avgPercentage.toStringAsFixed(1),
        'accuracy': accuracy.toStringAsFixed(1),
        'total_correct': totalCorrect,
        'total_wrong': totalWrong,
      };

      return {'attempts': quizReports, 'summary': summary};
    } catch (e) {
      throw Exception("Error generating quiz report: $e");
    }
  }

  // Start quiz attempt
  Future<void> startQuizAttempt({
    required String quizId,
    required String studentId,
    required int totalQuestions,
  }) async {
    try {
      final studentBatchId = await getStudentBatchId(studentId);
      if (studentBatchId == null) {
        throw Exception('Student batch not found');
      }

      final existingAttempt = await _supabase
          .from('student_quiz_attempts')
          .select()
          .eq('quiz_id', quizId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingAttempt != null && existingAttempt['status'] == 'submitted') {
        throw Exception('You have already attempted this quiz');
      }

      if (existingAttempt == null) {
        final response = await _supabase
            .from('student_quiz_attempts')
            .insert({
              'quiz_id': quizId,
              'student_id': studentId,
              'batch_id': studentBatchId,
              'total_questions': totalQuestions,
              'status': 'in_progress',
            })
            .select()
            .single();

        _currentAttempt = response;
      } else {
        _currentAttempt = existingAttempt;

        if (_currentAttempt['answers'] != null) {
          final previousAnswers = Map<String, String>.from(
            _currentAttempt['answers'],
          );
          _selectedAnswers = previousAnswers;
        }
      }

      _quizSubmitted = false;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Get quiz questions
  Future<void> getQuizQuestions(String quizId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*')
          .eq('quiz_id', quizId)
          .order('created_at');

      _quizQuestions = response;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Select answer for a question
  void selectAnswer(String questionId, String answer) {
    if (_quizSubmitted) return; // Prevent changes after submission

    _selectedAnswers[questionId] = answer;
    notifyListeners();
  }

  // Submit quiz attempt
  Future<Map<String, dynamic>> submitQuizAttempt({
    required String attemptId,
    required String studentId,
  }) async {
    try {
      // Calculate results
      int correctAnswers = 0;
      int totalMarks = 0;
      Map<String, dynamic> questionResults = {};

      for (var question in _quizQuestions) {
        final selectedAnswer = _selectedAnswers[question['id']];
        final isCorrect = selectedAnswer == question['correct_answer'];
        final marksObtained = isCorrect ? (question['marks'] as int) : 0;

        if (isCorrect) {
          correctAnswers++;
          totalMarks += marksObtained;
        }

        questionResults[question['id']] = {
          'selected_answer': selectedAnswer,
          'correct_answer': question['correct_answer'],
          'is_correct': isCorrect,
          'marks_obtained': marksObtained,
          'question_text': question['question_text'],
          'options': {
            'a': question['option_a'],
            'b': question['option_b'],
            'c': question['option_c'],
            'd': question['option_d'],
          },
          'explanation': question['explanation'],
        };
      }

      // Update attempt with results
      final response = await _supabase
          .from('student_quiz_attempts')
          .update({
            'correct_answers': correctAnswers,
            'wrong_answers': _quizQuestions.length - correctAnswers,
            'total_marks_obtained': totalMarks,
            'submitted_at': DateTime.now().toIso8601String(),
            'status': 'submitted',
            'answers': _selectedAnswers,
          })
          .eq('id', attemptId)
          .select()
          .single();

      _currentAttempt = response;
      _quizSubmitted = true;

      // Store results for display
      _quizResults = {
        'total_questions': _quizQuestions.length,
        'correct_answers': correctAnswers,
        'wrong_answers': _quizQuestions.length - correctAnswers,
        'total_marks_obtained': totalMarks,
        'question_results': questionResults,
      };

      // Refresh attempted quizzes list
      await getAttemptedQuizzes(studentId);

      notifyListeners();
      return _quizResults;
    } catch (error) {
      rethrow;
    }
  }

  // Get attempt details with results
  Future<void> getAttemptDetails(String attemptId) async {
    try {
      final response = await _supabase
          .from('student_quiz_attempts')
          .select('*, quizzes(*, batches(name))')
          .eq('id', attemptId)
          .single();

      _currentAttempt = response;

      // If quiz is submitted, load results
      if (_currentAttempt['status'] == 'submitted') {
        _quizSubmitted = true;
        await getQuizQuestions(_currentAttempt['quiz_id']);

        // Calculate results for display
        final questionResults = {};
        int correctAnswers = 0;

        for (var question in _quizQuestions) {
          final selectedAnswer = _currentAttempt['answers'] != null
              ? _currentAttempt['answers'][question['id']]
              : null;
          final isCorrect = selectedAnswer == question['correct_answer'];

          if (isCorrect) correctAnswers++;

          questionResults[question['id']] = {
            'selected_answer': selectedAnswer,
            'correct_answer': question['correct_answer'],
            'is_correct': isCorrect,
            'question_text': question['question_text'],
            'options': {
              'a': question['option_a'],
              'b': question['option_b'],
              'c': question['option_c'],
              'd': question['option_d'],
            },
            'explanation': question['explanation'],
          };
        }

        _quizResults = {
          'total_questions': _quizQuestions.length,
          'correct_answers': correctAnswers,
          'wrong_answers': _quizQuestions.length - correctAnswers,
          'total_marks_obtained': _currentAttempt['total_marks_obtained'],
          'question_results': questionResults,
        };
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Clear current attempt
  void clearCurrentAttempt() {
    _currentAttempt = null;
    _quizQuestions = [];
    _selectedAnswers = {};
    _quizSubmitted = false;
    _quizResults = {};
    notifyListeners();
  }

  // Check if student can attempt quiz
  Future<bool> canAttemptQuiz(String quizId, String studentId) async {
    try {
      final existingAttempt = await _supabase
          .from('student_quiz_attempts')
          .select('status')
          .eq('quiz_id', quizId)
          .eq('student_id', studentId)
          .maybeSingle();

      return existingAttempt == null ||
          existingAttempt['status'] != 'submitted';
    } catch (error) {
      return false;
    }
  }
}
