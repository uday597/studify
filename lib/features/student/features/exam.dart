import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/exam.dart';

class StudentExamsScreen extends StatefulWidget {
  final String studentId;
  final String batchId;
  final String studentName;

  const StudentExamsScreen({
    super.key,
    required this.studentId,
    required this.batchId,
    required this.studentName,
  });

  @override
  State<StudentExamsScreen> createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends State<StudentExamsScreen> {
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
      backgroundColor: Colors.white,
      body: Consumer<ExamsProvider>(
        builder: (context, examsProvider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                title: const Text(
                  'My Exams',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ExamsProvider>().fetchExamsByBatch(
                        widget.batchId,
                      );
                    },
                  ),
                ],
              ),

              // Student Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.lightBlueAccent,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.studentName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${examsProvider.exams.length} Exams',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading State
              if (examsProvider.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading Exams...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              // Empty State
              if (!examsProvider.loading && examsProvider.exams.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Exams Scheduled',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'There are no exams scheduled for your batch yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Exams List
              if (!examsProvider.loading && examsProvider.exams.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final exam = examsProvider.exams[index];
                    return _buildExamCard(exam, index);
                  }, childCount: examsProvider.exams.length),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam, int index) {
    final examDate = DateTime.parse(exam['exam_date']);
    final now = DateTime.now();
    final isToday =
        examDate.year == now.year &&
        examDate.month == now.month &&
        examDate.day == now.day;
    final isUpcoming = examDate.isAfter(now) || isToday;
    final daysDifference = examDate.difference(now).inDays;

    Color statusColor = Colors.grey;
    String statusText = 'PASSED';

    if (isToday) {
      statusColor = Colors.orange;
      statusText = 'TODAY';
    } else if (isUpcoming) {
      if (daysDifference == 1) {
        statusColor = Colors.red;
        statusText = 'TOMORROW';
      } else if (daysDifference <= 7) {
        statusColor = Colors.orange;
        statusText = 'SOON';
      } else {
        statusColor = Colors.green;
        statusText = 'UPCOMING';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getSubjectColor(exam['subject_name']),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSubjectIcon(exam['subject_name']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['exam_name'] ?? 'Unnamed Exam',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam['subject_name'] ?? 'General',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Exam Details
              Row(
                children: [
                  _buildDetailItem(
                    Icons.calendar_today,
                    _formatExamDate(exam['exam_date']),
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.access_time,
                    '${exam['start_time']?.toString().substring(0, 5) ?? '--:--'} - ${exam['end_time']?.toString().substring(0, 5) ?? '--:--'}',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildDetailItem(
                    Icons.assessment,
                    'Total: ${exam['total_marks'] ?? '100'}',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.flag,
                    'Pass: ${exam['passing_marks'] ?? '33'}',
                  ),
                ],
              ),

              // Instructions
              if (exam['instructions'] != null &&
                  exam['instructions'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exam['instructions'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Days Countdown
              if (isUpcoming && !isToday) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        daysDifference == 1
                            ? 'Tomorrow'
                            : 'In $daysDifference days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExamDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Tomorrow';
      if (difference > 1 && difference <= 7) return 'In $difference days';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getSubjectColor(String? subject) {
    final subjectName = (subject ?? '').toLowerCase();

    if (subjectName.contains('math') || subjectName.contains('गणित')) {
      return Colors.redAccent;
    } else if (subjectName.contains('science') ||
        subjectName.contains('विज्ञान')) {
      return Colors.green;
    } else if (subjectName.contains('english') ||
        subjectName.contains('अंग्रेजी')) {
      return Colors.blue;
    } else if (subjectName.contains('hindi') || subjectName.contains('हिंदी')) {
      return Colors.orange;
    } else if (subjectName.contains('social') ||
        subjectName.contains('सामाजिक')) {
      return Colors.purple;
    } else {
      return Colors.lightBlueAccent;
    }
  }

  IconData _getSubjectIcon(String? subject) {
    final subjectName = (subject ?? '').toLowerCase();

    if (subjectName.contains('math') || subjectName.contains('गणित')) {
      return Icons.calculate;
    } else if (subjectName.contains('science') ||
        subjectName.contains('विज्ञान')) {
      return Icons.science;
    } else if (subjectName.contains('english') ||
        subjectName.contains('अंग्रेजी')) {
      return Icons.language;
    } else if (subjectName.contains('hindi') || subjectName.contains('हिंदी')) {
      return Icons.translate;
    } else if (subjectName.contains('social') ||
        subjectName.contains('सामाजिक')) {
      return Icons.public;
    } else {
      return Icons.menu_book;
    }
  }
}
