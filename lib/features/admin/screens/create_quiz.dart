// quiz_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/admin/screens/create_questions.dart';
import 'package:studify/provider/quiz_teacher&admin.dart';

class QuizManagementScreen extends StatefulWidget {
  final String batchId;
  final String batchName;
  final int adminId;

  const QuizManagementScreen({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.adminId,
  });

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().getQuizzes(batchId: widget.batchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes - ${widget.batchName}'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showAddQuizDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: quizProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : quizProvider.quizzes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No quizzes found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first quiz',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizProvider.quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizProvider.quizzes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.quiz,
                      color: Colors.lightBlueAccent,
                    ),
                    title: Text(
                      quiz['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (quiz['subject'] != null)
                          Text('Subject: ${quiz['subject']}'),
                        Text('Marks: ${quiz['total_marks']}'),
                        Text(
                          'Status: ${quiz['is_published'] ? 'Published' : 'Draft'}',
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showQuizOptions(context, quiz);
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to quiz details/questions screen
                      _showQuizDetails(context, quiz['id']);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Add this import

  void _showAddQuizDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter quiz title')),
                );
                return;
              }

              try {
                final quizProvider = context.read<QuizProvider>();

                // ✅ Solution: Admin के लिए created_by NULL भेजें
                await quizProvider.createQuiz(
                  title: titleController.text,
                  batchId: widget.batchId,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  subject: subjectController.text.isEmpty
                      ? null
                      : subjectController.text,
                  durationMinutes: durationController.text.isEmpty
                      ? null
                      : int.parse(durationController.text),
                  createdBy: null, // ✅ NULL भेजें admin के लिए
                  adminId: widget.adminId,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Quiz "${titleController.text}" created successfully!',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error creating quiz: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text(
              'Create Quiz',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuizOptions(BuildContext context, dynamic quiz) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Quiz'),
            onTap: () {
              Navigator.pop(context);
              _showEditQuizDialog(context, quiz);
            },
          ),
          ListTile(
            leading: Icon(
              quiz['is_published'] ? Icons.visibility_off : Icons.visibility,
            ),
            title: Text(quiz['is_published'] ? 'Unpublish' : 'Publish'),
            onTap: () {
              Navigator.pop(context);
              _toggleQuizPublishStatus(context, quiz);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Quiz',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, quiz);
            },
          ),
        ],
      ),
    );
  }

  void _showEditQuizDialog(BuildContext context, dynamic quiz) {
    final titleController = TextEditingController(text: quiz['title']);
    final subjectController = TextEditingController(
      text: quiz['subject'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: quiz['description'] ?? '',
    );
    final durationController = TextEditingController(
      text: quiz['duration_minutes']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter quiz title')),
                );
                return;
              }

              try {
                final quizProvider = context.read<QuizProvider>();
                await quizProvider.updateQuiz(
                  quizId: quiz['id'],
                  title: titleController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  subject: subjectController.text.isEmpty
                      ? null
                      : subjectController.text,
                  durationMinutes: durationController.text.isEmpty
                      ? null
                      : int.parse(durationController.text),
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Quiz "${titleController.text}" updated successfully!',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating quiz: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text(
              'Update Quiz',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleQuizPublishStatus(BuildContext context, dynamic quiz) async {
    try {
      final quizProvider = context.read<QuizProvider>();
      await quizProvider.updateQuiz(
        quizId: quiz['id'],
        isPublished: !quiz['is_published'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quiz ${!quiz['is_published'] ? 'published' : 'unpublished'} successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, dynamic quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final quizProvider = context.read<QuizProvider>();
                await quizProvider.deleteQuiz(quiz['id']);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Quiz "${quiz['title']}" deleted successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting quiz: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuizDetails(BuildContext context, String quizId) {
    final quiz = context.read<QuizProvider>().quizzes.firstWhere(
      (q) => q['id'] == quizId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetailsScreen(
          quizId: quizId,
          quizTitle: quiz['title'],
          batchName: widget.batchName,
        ),
      ),
    );
  }
}
