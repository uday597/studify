import 'package:flutter/material.dart';
import 'package:studify/features/admin/screens/exam_batch.dart';
import 'package:studify/features/teacher/screens/batch_quiz.dart';
import 'package:studify/features/teacher/screens/leave_manager.dart';
import 'package:studify/features/teacher/teacher_profile.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/utils/reuselist.dart';

class TeacherDashboard extends StatefulWidget {
  final Map<String, dynamic> teacherData;
  const TeacherDashboard({super.key, required this.teacherData});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Dashboard'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherProfile2(TecherData: widget.teacherData),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/images/stulogo.png',
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome ${widget.teacherData['name']}',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 10),

                            // EMAIL
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.teacherData['email'] ?? 'No email',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // PHONE
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.teacherData['mobile'] ?? 'No phone',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // LOCATION
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.teacherData['location'] ??
                                        'No location',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/batcheslist');
              },
              image: 'assets/images/batchicon.png',
              text: 'Batch Details',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacheracademyinfo');
              },
              image: 'assets/images/studenticon.png',
              text: 'My Academy',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacher_attendacne_history');
              },
              image: 'assets/images/attendanceicon.png',
              text: 'Attendance',
            ),
            reuseList(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamBatchSelectionScreen(
                      userType: 'teacher',
                      userId: widget.teacherData['id'],
                      adminId: widget.teacherData['admin_id'],
                    ),
                  ),
                );
              },
              image: 'assets/images/exam.png',
              text: 'Manage Exam',
            ),
            reuseList(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherLeave(
                      adminId: widget.teacherData['admin_id'],
                      teacherId: widget.teacherData['id'],
                    ),
                  ),
                );
              },
              image: 'assets/images/questioning.png',
              text: 'Leave Manager',
            ),
            reuseList(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherBatchSelectionScreen(
                      teacherData: widget.teacherData,
                    ),
                  ),
                );
              },
              image: 'assets/images/ideas.png',
              text: 'Quiz',
            ),

            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacherbatches');
              },
              image: 'assets/images/homework.png',
              text: 'Homework',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              image: 'assets/images/settingsicon.png',
              text: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
