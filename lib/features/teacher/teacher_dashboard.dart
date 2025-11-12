import 'package:flutter/material.dart';
import 'package:studify/features/teacher/teacher_profile.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/utils/coming_soon.dart';
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
                          'Welcome ${widget.teacherData['name']}',
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
              onTap: () {},
              color: Colors.deepOrange,
              image: 'assets/images/batchicon.png',
              text: 'Batch Details',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacheracademyinfo');
              },
              color: Colors.teal,
              image: 'assets/images/studenticon.png',
              text: 'My Academy',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacher_attendacne_history');
              },
              color: Colors.lightBlue,
              image: 'assets/images/attendanceicon.png',
              text: 'Attendance',
            ),
            reuseList(
              onTap: () {},
              color: Colors.purple,
              image: 'assets/images/stafficon.png',
              text: 'Student List',
            ),
            reuseList(
              onTap: () {
                Navigator.pushNamed(context, '/teacherbatches');
              },
              color: Colors.red,
              image: 'assets/images/feesicon.png',
              text: 'Homework',
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
