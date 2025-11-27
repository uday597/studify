import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/exam.dart';
import 'package:studify/utils/exam_dilog.dart';

class ExamManagementScreen extends StatefulWidget {
  final String batchId;
  final String batchName;
  final String userType;
  final String userId;
  final int? adminId;
  const ExamManagementScreen({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.userType,
    required this.userId,
    this.adminId,
  });

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamsProvider>().fetchExamsByBatch(widget.batchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exams - ${widget.batchName}'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ExamsProvider>().fetchExamsByBatch(widget.batchId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExamDialog(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<ExamsProvider>(
        builder: (context, examsProvider, child) {
          if (examsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (examsProvider.exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No exams scheduled'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddExamDialog(context),
                    child: const Text('Add First Exam'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<ExamsProvider>().fetchExamsByBatch(
                widget.batchId,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: examsProvider.exams.length,
              itemBuilder: (context, index) {
                final exam = examsProvider.exams[index];
                return _buildExamCard(exam, context);
              },
            ),
          );
        },
      ),
    );
  }

  // ✅ Add this missing method
  Widget _buildExamCard(Map<String, dynamic> exam, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exam['exam_name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                PopupMenuButton(
                  color: Colors.white,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditExamDialog(context, exam);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, exam['id']);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Subject: ${exam['subject_name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${exam['exam_date'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${exam['start_time'] ?? 'N/A'} - ${exam['end_time'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Marks: ${exam['total_marks'] ?? 'N/A'} (Pass: ${exam['passing_marks'] ?? 'N/A'})',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            if (exam['instructions'] != null &&
                exam['instructions'].isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Instructions: ${exam['instructions']}',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExamDialog(
        batchId: widget.batchId,
        userType: widget.userType,
        userId: widget.userId,
        adminId: widget.adminId,
      ),
    );
  }

  void _showEditExamDialog(BuildContext context, Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (context) => ExamDialog(
        batchId: widget.batchId,
        userType: widget.userType,
        userId: widget.userId,
        adminId: widget.adminId,
        exam: exam,
        isEdit: true,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String examId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExamsProvider>().deleteExam(examId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
