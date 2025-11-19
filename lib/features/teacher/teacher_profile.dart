import 'package:flutter/material.dart';
import 'package:studify/features/admin/profile/adminprofile.dart';
import 'package:studify/utils/appbar.dart';

class TeacherProfile2 extends StatefulWidget {
  final Map<String, dynamic> TecherData;
  const TeacherProfile2({super.key, required this.TecherData});

  @override
  State<TeacherProfile2> createState() => _TeacherProfile2State();
}

class _TeacherProfile2State extends State<TeacherProfile2> {
  @override
  Widget build(BuildContext context) {
    final teacher = widget.TecherData;

    return Scaffold(
      appBar: ReuseAppbar(name: 'Student Profile'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                backgroundImage: const AssetImage(
                  'assets/images/teacherlogo.jpg',
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "teacher Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 15),

            // 📝 Student Info
            Card(
              color: Colors.white,
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    buildTextField(label: teacher['name'], icon: Icons.person),
                    buildTextField(label: teacher['email'], icon: Icons.mail),

                    buildTextField(label: teacher['mobile'], icon: Icons.phone),
                    buildTextField(
                      label: teacher['salary'],
                      icon: Icons.person_2,
                    ),
                    buildTextField(
                      label: teacher['address'],
                      icon: Icons.location_on,
                    ),
                    buildTextField(
                      label: teacher['password'],
                      icon: Icons.password,
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
