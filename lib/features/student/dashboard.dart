import 'package:flutter/material.dart';
import 'package:studify/features/student/features/homework.dart';
import 'package:studify/features/student/studentoprofile.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/utils/coming_soon.dart';
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Color.fromARGB(100, 0, 0, 0),
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(
                          'assets/images/stulogo.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome ${widget.studentData['name']}',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          overflow: TextOverflow.ellipsis,
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
              color: Colors.deepOrange,
              image: 'assets/images/batchicon.png',
              text: 'Batch Details',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/academyinfo');
              },
              color: Colors.teal,
              image: 'assets/images/studenticon.png',
              text: 'My Academy',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/studentattendancehistory');
              },
              color: Colors.lightBlue,
              image: 'assets/images/attendanceicon.png',
              text: 'Attendance',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/feeshistory');
              },
              color: Colors.purpleAccent,
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
              color: Colors.redAccent,
              image: 'assets/images/feesicon.png',
              text: 'Homework',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/contactsupport');
              },
              color: Colors.green,
              image: 'assets/images/contactuslogo.png',
              text: 'Contact Us',
            ),
            reuseList(
              onTap: () {
                showComingSoon(context);
              },
              color: Colors.blueGrey,
              image: 'assets/images/settingsicon.png',
              text: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
