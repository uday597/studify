// student_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/student/features/quiz.dart';
import 'package:studify/provider/student/quiz.dart';

class StudentQuizScreen extends StatefulWidget {
  final String studentId;

  const StudentQuizScreen({super.key, required this.studentId});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final provider = context.read<StudentQuizProvider>();
      await provider.getAvailableQuizzes(widget.studentId);
      await provider.getAttemptedQuizzes(widget.studentId);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: _currentIndex == 0
          ? _buildAvailableQuizzes()
          : _buildAttemptedQuizzes(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Available'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Attempted',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableQuizzes() {
    final provider = Provider.of<StudentQuizProvider>(context);

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.availableQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No quizzes available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Your teacher will publish quizzes soon',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.availableQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = provider.availableQuizzes[index];

        // ✅ Null check add करें
        final quizId = quiz['id']?.toString() ?? '';
        final title = quiz['title']?.toString() ?? 'Untitled Quiz';
        final subject = quiz['subject']?.toString();
        final totalMarks = quiz['total_marks']?.toString() ?? '0';
        final batchName = quiz['batches'] != null
            ? (quiz['batches']['name']?.toString() ?? 'No Batch')
            : 'No Batch';

        if (quizId.isEmpty) {
          return const SizedBox(); // Skip invalid quizzes
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.quiz, color: Colors.lightBlueAccent),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subject != null && subject.isNotEmpty)
                  Text('Subject: $subject'),
                Text('Total Marks: $totalMarks'),
                Text('Batch: $batchName'),
              ],
            ),
            trailing: FutureBuilder<bool>(
              future: provider.canAttemptQuiz(quizId, widget.studentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final canAttempt = snapshot.data ?? true;
                return ElevatedButton(
                  onPressed: canAttempt
                      ? () {
                          _startQuizAttempt(context, quiz);
                        }
                      : null,
                  child: const Text('Start'),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttemptedQuizzes() {
    final provider = Provider.of<StudentQuizProvider>(context);

    if (provider.attemptedQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No quiz attempts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Attempt quizzes from Available tab',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.attemptedQuizzes.length,
      itemBuilder: (context, index) {
        final attempt = provider.attemptedQuizzes[index];

        // ✅ Null check add करें
        final quiz = attempt['quizzes'] ?? {};
        final quizTitle = quiz['title']?.toString() ?? 'Unknown Quiz';
        final totalMarks = quiz['total_marks']?.toString() ?? '0';
        final obtainedMarks =
            attempt['total_marks_obtained']?.toString() ?? '0';
        final correctAnswers = attempt['correct_answers']?.toString() ?? '0';
        final totalQuestions = attempt['total_questions']?.toString() ?? '0';
        final submittedAt = attempt['submitted_at']?.toString() ?? '';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(
              Icons.assignment_turned_in,
              color: Colors.green,
            ),
            title: Text(
              quizTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: $obtainedMarks/$totalMarks'),
                Text('Correct: $correctAnswers/$totalQuestions'),
                if (submittedAt.isNotEmpty)
                  Text('Submitted: ${_formatDate(submittedAt)}'),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                final attemptId = attempt['id']?.toString();
                if (attemptId != null && attemptId.isNotEmpty) {
                  _viewQuizResults(context, attemptId);
                }
              },
              icon: const Icon(Icons.visibility),
            ),
          ),
        );
      },
    );
  }

  void _startQuizAttempt(BuildContext context, dynamic quiz) {
    // ✅ Null check add करें
    final quizId = quiz['id']?.toString();
    if (quizId == null || quizId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid quiz data')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizAttemptScreen(quiz: quiz, studentId: widget.studentId),
      ),
    );
  }

  void _viewQuizResults(BuildContext context, String attemptId) {
    // Results screen implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing results for attempt: $attemptId')),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
