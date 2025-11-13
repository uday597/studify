import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/teacher.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/utils/appbar.dart'; // Add this import

class TeacherAttendanceScreen extends StatefulWidget {
  final int adminId;
  const TeacherAttendanceScreen({super.key, required this.adminId});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  Map<String, String> attendanceStatus = {}; // teacherId -> status

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final teacherProvider = Provider.of<TeacherProvider>(
        context,
        listen: false,
      );
      final adminProvider = Provider.of<AdminProfileProvider>(
        context,
        listen: false,
      );

      adminProvider.ensureAdminLoaded().then((_) {
        if (adminProvider.adminId != null) {
          teacherProvider.fatchTeachers(adminId: adminProvider.adminId!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Mark Teacher Attendance'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add date display
            Card(
              color: Colors.white,
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
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: teacherProvider.teachers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No teachers available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Add teachers first to mark attendance',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: teacherProvider.teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = teacherProvider.teachers[index];
                        final teacherId = teacher['id'];
                        final currentStatus =
                            attendanceStatus[teacherId] ?? 'Present';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(currentStatus),
                              child: Text(
                                teacher['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              teacher['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teacher['email'] ?? 'No email'),
                                const SizedBox(height: 4),
                                Text(
                                  'Mobile: ${teacher['mobile'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  currentStatus,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(currentStatus),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: currentStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Present',
                                    child: Text(
                                      'Present',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Absent',
                                    child: Text(
                                      'Absent',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Leave',
                                    child: Text(
                                      'Leave',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    attendanceStatus[teacherId] = value!;
                                  });
                                },
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (teacherProvider.teachers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: attendanceProvider.loading
                      ? null
                      : () async {
                          // 🔥 CHECK ADMIN ID
                          final adminProvider =
                              Provider.of<AdminProfileProvider>(
                                context,
                                listen: false,
                              );
                          await adminProvider.ensureAdminLoaded();

                          if (adminProvider.adminId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Admin not logged in properly'),
                              ),
                            );
                            return;
                          }

                          try {
                            int markedCount = 0;
                            for (var teacher in teacherProvider.teachers) {
                              final teacherId = teacher['id'];
                              final status =
                                  attendanceStatus[teacherId] ?? 'Present';
                              await attendanceProvider.markTeacherAttendance(
                                teacherId: teacherId,
                                status: status,
                                adminId: adminProvider.adminId!, // ✅ SAFE NOW
                              );
                              markedCount++;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Attendance marked for $markedCount teachers!',
                                ),
                              ),
                            );

                            setState(() {
                              attendanceStatus.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  icon: attendanceProvider.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: attendanceProvider.loading
                      ? const Text('Saving...')
                      : const Text('Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'Present':
      return Colors.green;
    case 'Absent':
      return Colors.red;
    case 'Leave':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
