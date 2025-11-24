// quiz_attempt_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/student/quiz.dart';

class QuizAttemptScreen extends StatefulWidget {
  final dynamic quiz;
  final String studentId;

  const QuizAttemptScreen({
    super.key,
    required this.quiz,
    required this.studentId,
  });

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final provider = context.read<StudentQuizProvider>();
    await provider.startQuizAttempt(
      quizId: widget.quiz['id'],
      studentId: widget.studentId,
      totalQuestions:
          widget.quiz['total_marks'], // Assuming 1 mark per question
    );
    await provider.getQuizQuestions(widget.quiz['id']);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentQuizProvider>(context);

    if (provider.loading || provider.quizQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = provider.quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title']),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (!provider.quizSubmitted)
            TextButton(
              onPressed: () => _showSubmitConfirmation(context),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: provider.quizSubmitted
          ? _buildResults(provider)
          : _buildQuizQuestions(provider, currentQuestion),
      bottomNavigationBar: provider.quizSubmitted
          ? null
          : _buildBottomNav(provider),
    );
  }

  Widget _buildQuizQuestions(
    StudentQuizProvider provider,
    dynamic currentQuestion,
  ) {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / provider.quizQuestions.length,
        ),

        // Question navigation
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${provider.quizQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${currentQuestion['marks']} mark${currentQuestion['marks'] > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Question and options
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.quizQuestions.length,
            itemBuilder: (context, index) {
              final question = provider.quizQuestions[index];
              return _buildQuestionCard(provider, question);
            },
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(StudentQuizProvider provider, dynamic question) {
    final selectedAnswer = provider.selectedAnswers[question['id']];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question_text'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildOption(
            'A',
            question['option_a'],
            question['id'],
            selectedAnswer,
            provider,
          ),
          _buildOption(
            'B',
            question['option_b'],
            question['id'],
            selectedAnswer,
            provider,
          ),
          _buildOption(
            'C',
            question['option_c'],
            question['id'],
            selectedAnswer,
            provider,
          ),
          _buildOption(
            'D',
            question['option_d'],
            question['id'],
            selectedAnswer,
            provider,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    String option,
    String text,
    String questionId,
    String? selectedAnswer,
    StudentQuizProvider provider,
  ) {
    final isSelected = selectedAnswer == option.toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.lightBlueAccent.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightBlueAccent : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(text),
        onTap: () {
          provider.selectAnswer(questionId, option.toLowerCase());
        },
      ),
    );
  }

  Widget _buildBottomNav(StudentQuizProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentQuestionIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: const Text('Previous'),
          ),
          ElevatedButton(
            onPressed: _currentQuestionIndex < provider.quizQuestions.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(StudentQuizProvider provider) {
    final results = provider.quizResults;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz Submitted Successfully!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: ${results['total_marks_obtained']}/${widget.quiz['total_marks']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct Answers: ${results['correct_answers']}/${results['total_questions']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...provider.quizQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final questionResult = results['question_results'][question['id']];

            return _buildQuestionReview(question, questionResult, index);
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Quizzes'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(dynamic question, dynamic result, int index) {
    final isCorrect = result['is_correct'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCorrect ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Q${index + 1}. ${question['question_text']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your Answer: ${_getOptionText(result['selected_answer'], result['options'])}',
            ),
            Text(
              'Correct Answer: ${_getOptionText(result['correct_answer'], result['options'])}',
            ),
            if (question['explanation'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Explanation: ${question['explanation']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getOptionText(String? option, Map<String, dynamic> options) {
    if (option == null) return 'Not attempted';
    return '${option.toUpperCase()}. ${options[option]}';
  }

  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: const Text(
          'Are you sure you want to submit the quiz? You cannot change answers after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitQuiz(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz(BuildContext context) async {
    final provider = context.read<StudentQuizProvider>();
    try {
      await provider.submitQuizAttempt(
        attemptId: provider.currentAttempt['id'],
        studentId: widget.studentId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
