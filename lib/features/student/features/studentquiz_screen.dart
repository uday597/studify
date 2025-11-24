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
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<StudentQuizProvider>();
    await provider.getAvailableQuizzes(widget.studentId);
    await provider.getAttemptedQuizzes(widget.studentId);
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
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.quiz, color: Colors.lightBlueAccent),
            title: Text(
              quiz['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (quiz['subject'] != null)
                  Text('Subject: ${quiz['subject']}'),
                Text('Total Marks: ${quiz['total_marks']}'),
                Text('Batch: ${quiz['batches']['name']}'),
              ],
            ),
            trailing: FutureBuilder<bool>(
              future: provider.canAttemptQuiz(quiz['id'], widget.studentId),
              builder: (context, snapshot) {
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
        final quiz = attempt['quizzes'];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(
              Icons.assignment_turned_in,
              color: Colors.green,
            ),
            title: Text(
              quiz['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: ${attempt['total_marks_obtained']}/${quiz['total_marks']}',
                ),
                Text(
                  'Correct: ${attempt['correct_answers']}/${attempt['total_questions']}',
                ),
                Text('Submitted: ${_formatDate(attempt['submitted_at'])}'),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                _viewQuizResults(context, attempt['id']);
              },
              icon: const Icon(Icons.visibility),
            ),
          ),
        );
      },
    );
  }

  void _startQuizAttempt(BuildContext context, dynamic quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizAttemptScreen(
          // ✅ अब QuizAttemptScreen call करें
          quiz: quiz,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _viewQuizResults(BuildContext context, String attemptId) {
    // Results screen implementation
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
