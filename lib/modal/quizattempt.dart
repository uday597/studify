class QuizAttempt {
  final String id;
  final String quizId;
  final String studentId;
  final String selectedOption;
  final int? score;
  final DateTime attemptedAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.selectedOption,
    this.score,
    required this.attemptedAt,
  });

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'].toString(),
      quizId: map['quiz_id'].toString(),
      studentId: map['student_id'].toString(),
      selectedOption: map['selected_option'] ?? '',
      score: map['score'],
      attemptedAt: DateTime.parse(
        map['attempted_at'] ?? DateTime.now().toString(),
      ),
    );
  }
}
