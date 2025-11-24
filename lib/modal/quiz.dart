class Quiz {
  final String id;
  final String quizTitle;
  final String batchId;
  final String createdByRole;
  final String createdById;
  final String questionText;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String correctAnswer;
  final String? note;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.quizTitle,
    required this.batchId,
    required this.createdByRole,
    required this.createdById,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswer,
    this.note,
    required this.createdAt,
  });

  // Map se object me convert
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'].toString(),
      quizTitle: map['quiz_title'] ?? '',
      batchId: map['batch_id'] ?? '',
      createdByRole: map['created_by_role'] ?? '',
      createdById: map['created_by_id'].toString(),
      questionText: map['question_text'] ?? '',
      option1: map['option1'] ?? '',
      option2: map['option2'] ?? '',
      option3: map['option3'] ?? '',
      option4: map['option4'] ?? '',
      correctAnswer: map['correct_answer'] ?? '',
      note: map['note'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
    );
  }
}
