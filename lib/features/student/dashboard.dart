import 'package:flutter/material.dart';
import 'package:studify/features/student/features/exam.dart';
import 'package:studify/features/student/features/homework.dart';
import 'package:studify/features/student/features/studentquiz_screen.dart';
import 'package:studify/features/student/studentoprofile.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/utils/reuselist.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const StudentDashboard({super.key, required this.studentData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Welcome Student'),
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
                          StudentProfile2(studenData: widget.studentData),
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

                      // DETAILS AREA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME
                            Text(
                              'Welcome ${widget.studentData['name']}',
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
                                    widget.studentData['email'] ?? 'No email',
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
                                  widget.studentData['mobile'] ?? 'No phone',
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
                                    widget.studentData['address'] ??
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
                Navigator.pushNamed(context, '/batchinfo');
              },
              image: 'assets/images/batchicon.png',
              text: 'Batch Details',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/academyinfo');
              },
              image: 'assets/images/studenticon.png',
              text: 'My Academy',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/studentattendancehistory');
              },
              image: 'assets/images/attendanceicon.png',
              text: 'Attendance',
            ),
            reuseList(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentExamsScreen(
                      studentId: widget.studentData['id'],
                      batchId: widget.studentData['batch_id'],
                      studentName: widget.studentData['name'],
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
                    builder: (context) =>
                        StudentQuizScreen(studentId: widget.studentData['id']),
                  ),
                );
              },
              image: 'assets/images/ideas.png',
              text: 'Quiz',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/feeshistory');
              },
              image: 'assets/images/stafficon.png',
              text: 'Tution Fees',
            ),
            reuseList(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentHomework(
                      batchId: widget.studentData['batch_id'],
                      adminId: widget.studentData['admin_id'],
                    ),
                  ),
                );
              },
              image: 'assets/images/homework.png',
              text: 'Homework',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/contactsupport');
              },
              image: 'assets/images/contactuslogo.png',
              text: 'Contact Us',
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
