import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/screens/admin/features/staff_attendance.dart';
import 'package:studify/utils/appbar.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final int adminId;
  const StudentAttendanceScreen({super.key, required this.adminId});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String? selectedBatchId;
  Map<String, String> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final adminProvider = Provider.of<AdminProfileProvider>(
        context,
        listen: false,
      );
      final batchProvider = Provider.of<BatchProvider>(context, listen: false);

      adminProvider.ensureAdminLoaded().then((_) {
        if (adminProvider.adminId != null) {
          batchProvider.fetchData(adminId: adminProvider.adminId!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProfileProvider>(context);
    final batchProvider = Provider.of<BatchProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Mark Student Attendance'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Batch',
                border: OutlineInputBorder(),
              ),
              value: selectedBatchId,
              items: batchProvider.batches.map((batch) {
                return DropdownMenuItem<String>(
                  value: batch['id'].toString(),
                  child: Text(batch['name']),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  selectedBatchId = value;
                });
                if (value != null && adminProvider.adminId != null) {
                  await studentProvider.fetchStudentsByBatch(
                    value,
                    adminProvider.adminId!,
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            if (selectedBatchId == null)
              const Center(
                child: Text('Please select a batch to view students'),
              )
            else if (studentProvider.StudentList.isEmpty)
              const Center(child: Text('No students found in this batch'))
            else
              Expanded(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: studentProvider.StudentList.length,
                    itemBuilder: (context, index) {
                      final student = studentProvider.StudentList[index];
                      final studentId = student['id'];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(student['name'][0].toUpperCase()),
                          ),
                          title: Text(student['name']),
                          subtitle: Text(student['email'] ?? 'No email'),
                          trailing: DropdownButton<String>(
                            value: attendanceStatus[studentId] ?? 'Present',
                            items: const [
                              DropdownMenuItem(
                                value: 'Present',
                                child: Text('Present'),
                              ),
                              DropdownMenuItem(
                                value: 'Absent',
                                child: Text('Absent'),
                              ),
                              DropdownMenuItem(
                                value: 'Leave',
                                child: Text('Leave'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  attendanceStatus[studentId] = value;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (selectedBatchId != null &&
                studentProvider.StudentList.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: attendanceProvider.loading
                      ? null
                      : () async {
                          if (adminProvider.adminId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin not logged in properly'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            int markedCount = 0;
                            for (var student in studentProvider.StudentList) {
                              final studentId = student['id'];
                              final status =
                                  attendanceStatus[studentId] ?? 'Present';

                              await attendanceProvider.markStudentAttendance(
                                studentId: studentId,
                                batchId: selectedBatchId!,
                                status: status,
                                adminId: adminProvider
                                    .adminId!, // Use from adminProvider
                              );
                              markedCount++;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Attendance marked for $markedCount students! ✅',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Clear selections after successful submission
                            setState(() {
                              attendanceStatus.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error marking attendance: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check),
                  label: attendanceProvider.loading
                      ? const Text('Submitting...')
                      : const Text('Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
