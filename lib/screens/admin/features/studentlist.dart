import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/screens/admin/features/studentprofile.dart';
import 'package:studify/utils/appbar.dart';

class StudentListScreen extends StatefulWidget {
  final String batchId;
  final String batchName;

  const StudentListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final adminProvider = Provider.of<AdminProfileProvider>(
      context,
      listen: false,
    );
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    await adminProvider.ensureAdminLoaded();

    if (adminProvider.adminId != null) {
      await studentProvider.fetchStudentsByBatch(
        widget.batchId,
        adminProvider.adminId!,
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final students = studentProvider.StudentList;

    return Scaffold(
      appBar: ReuseAppbar(name: '${widget.batchName} - Students'),
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
                  // 🟩 Hint text for admin
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
                                _getSafeInitial(
                                  student['name'],
                                ), // Safe initial
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              _getSafeString(student['name']), // Safe name
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _getSafeString(student['email']), // Safe email
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
                                  builder: (context) =>
                                      StudentProfile(studentData: student),
                                ),
                              );
                            },
                          ),
                        );
                      },

                      // Add these helper methods to StudentListScreen
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

String _getSafeString(dynamic value) {
  if (value == null) return 'Not provided';
  return value.toString();
}

String _getSafeInitial(dynamic name) {
  if (name == null || name.toString().isEmpty) return '?';
  return name.toString()[0].toUpperCase();
}
