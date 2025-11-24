// quiz_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/quiz_teacher&admin.dart';

class QuizDetailsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String batchName;

  const QuizDetailsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.batchName,
  });

  @override
  State<QuizDetailsScreen> createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().getQuestions(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showAddQuestionDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quiz Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.quizTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Batch: ${widget.batchName}'),
                  const SizedBox(height: 4),
                  Text('Total Questions: ${quizProvider.questions.length}'),
                  const SizedBox(height: 4),
                  Text(
                    'Total Marks: ${_calculateTotalMarks(quizProvider.questions)}',
                  ),
                ],
              ),
            ),
          ),

          // Questions List
          Expanded(
            child: quizProvider.questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.question_mark,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No questions added yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first question',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: quizProvider.questions.length,
                    itemBuilder: (context, index) {
                      final question = quizProvider.questions[index];
                      return _buildQuestionCard(context, question, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, dynamic question, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Q${index + 1}.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${question['marks']} mark${question['marks'] > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question['question_text'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildOption('A', question['option_a'], question['correct_answer']),
            _buildOption('B', question['option_b'], question['correct_answer']),
            _buildOption('C', question['option_c'], question['correct_answer']),
            _buildOption('D', question['option_d'], question['correct_answer']),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    _showEditQuestionDialog(context, question);
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteQuestionConfirmation(context, question);
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, String text, String correctAnswer) {
    final isCorrect = option.toLowerCase() == correctAnswer.toLowerCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.grey[50],
        border: Border.all(color: isCorrect ? Colors.green : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.grey[300]!,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: isCorrect ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isCorrect ? Colors.green[800] : Colors.black,
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isCorrect)
            Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    final questionController = TextEditingController();
    final optionAController = TextEditingController();
    final optionBController = TextEditingController();
    final optionCController = TextEditingController();
    final optionDController = TextEditingController();
    final explanationController = TextEditingController();
    final marksController = TextEditingController(text: '1');

    String? selectedCorrectAnswer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionAController,
                  decoration: const InputDecoration(
                    labelText: 'Option A*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionBController,
                  decoration: const InputDecoration(
                    labelText: 'Option B*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionCController,
                  decoration: const InputDecoration(
                    labelText: 'Option C*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionDController,
                  decoration: const InputDecoration(
                    labelText: 'Option D*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Correct Answer:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['A', 'B', 'C', 'D'].map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: selectedCorrectAnswer == option.toLowerCase(),
                      onSelected: (selected) {
                        setState(() {
                          selectedCorrectAnswer = option.toLowerCase();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                if (questionController.text.isEmpty ||
                    optionAController.text.isEmpty ||
                    optionBController.text.isEmpty ||
                    optionCController.text.isEmpty ||
                    optionDController.text.isEmpty ||
                    selectedCorrectAnswer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                try {
                  final quizProvider = context.read<QuizProvider>();
                  await quizProvider.addQuestion(
                    quizId: widget.quizId,
                    questionText: questionController.text,
                    optionA: optionAController.text,
                    optionB: optionBController.text,
                    optionC: optionCController.text,
                    optionD: optionDController.text,
                    correctAnswer: selectedCorrectAnswer!,
                    explanation: explanationController.text.isEmpty
                        ? null
                        : explanationController.text,
                    marks: int.parse(marksController.text),
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding question: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text(
                'Add Question',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuestionDialog(BuildContext context, dynamic question) {
    final questionController = TextEditingController(
      text: question['question_text'],
    );
    final optionAController = TextEditingController(text: question['option_a']);
    final optionBController = TextEditingController(text: question['option_b']);
    final optionCController = TextEditingController(text: question['option_c']);
    final optionDController = TextEditingController(text: question['option_d']);
    final explanationController = TextEditingController(
      text: question['explanation'] ?? '',
    );
    final marksController = TextEditingController(
      text: question['marks'].toString(),
    );

    String selectedCorrectAnswer = question['correct_answer'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionAController,
                  decoration: const InputDecoration(
                    labelText: 'Option A*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionBController,
                  decoration: const InputDecoration(
                    labelText: 'Option B*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionCController,
                  decoration: const InputDecoration(
                    labelText: 'Option C*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: optionDController,
                  decoration: const InputDecoration(
                    labelText: 'Option D*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Correct Answer:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['A', 'B', 'C', 'D'].map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: selectedCorrectAnswer == option.toLowerCase(),
                      onSelected: (selected) {
                        setState(() {
                          selectedCorrectAnswer = option.toLowerCase();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                if (questionController.text.isEmpty ||
                    optionAController.text.isEmpty ||
                    optionBController.text.isEmpty ||
                    optionCController.text.isEmpty ||
                    optionDController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                try {
                  final quizProvider = context.read<QuizProvider>();
                  await quizProvider.updateQuestion(
                    questionId: question['id'],
                    questionText: questionController.text,
                    optionA: optionAController.text,
                    optionB: optionBController.text,
                    optionC: optionCController.text,
                    optionD: optionDController.text,
                    correctAnswer: selectedCorrectAnswer,
                    explanation: explanationController.text.isEmpty
                        ? null
                        : explanationController.text,
                    marks: int.parse(marksController.text),
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating question: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text(
                'Update Question',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteQuestionConfirmation(BuildContext context, dynamic question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final quizProvider = context.read<QuizProvider>();
                await quizProvider.deleteQuestion(question['id']);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting question: $e'),
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

  int _calculateTotalMarks(List<dynamic> questions) {
    return questions.fold(
      0,
      (sum, question) => sum + (question['marks'] as int),
    );
  }
}
