import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/teacher/screens/student_profile.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';

class BatchStudentList extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchStudentList({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchStudentList> createState() => _BatchStudentListState();
}

class _BatchStudentListState extends State<BatchStudentList> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStudents();
    });
  }

  Future<void> fetchStudents() async {
    final teacherData = Provider.of<TeacherLoginProvider>(
      context,
      listen: false,
    ).teacherData;
    if (teacherData == null || teacherData['admin_id'] == null) return;

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    setState(() => _isLoading = true);

    await studentProvider.fetchStudentsByBatch(
      widget.batchId,
      teacherData['admin_id'],
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final students = studentProvider.StudentList;

    return Scaffold(
      appBar: ReuseAppbar(name: '${widget.batchName} - Students'),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
          ? const Center(
              child: Text(
                'No students found for this batch 😔',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "👆 Tap on a student card to view full profile",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                _getSafeInitial(student['name']),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              _getSafeString(student['name']),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _getSafeString(student['email']),
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherStudentProfile(
                                    studentData: student,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Helper methods
String _getSafeString(dynamic value) {
  if (value == null || value.toString().isEmpty) return 'Not provided';
  return value.toString();
}

String _getSafeInitial(dynamic name) {
  if (name == null || name.toString().isEmpty) return '?';
  return name.toString()[0].toUpperCase();
}
