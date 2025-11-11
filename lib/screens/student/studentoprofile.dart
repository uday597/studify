import 'package:flutter/material.dart';
import 'package:studify/screens/admin/profile/adminprofile.dart';
import 'package:studify/utils/appbar.dart';

class StudentProfile2 extends StatefulWidget {
  final Map<String, dynamic> studenData;
  const StudentProfile2({super.key, required this.studenData});

  @override
  State<StudentProfile2> createState() => _StudentProfile2State();
}

class _StudentProfile2State extends State<StudentProfile2> {
  @override
  Widget build(BuildContext context) {
    final student = widget.studenData;

    return Scaffold(
      appBar: ReuseAppbar(name: 'Student Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🧑‍🎓 Student Logo
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                backgroundImage: const AssetImage(
                  'assets/images/studenttlogo.png',
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Student Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 15),

            // 📝 Student Info
            Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    buildTextField(label: student['name'], icon: Icons.person),
                    buildTextField(label: student['email'], icon: Icons.mail),

                    buildTextField(label: student['mobile'], icon: Icons.phone),
                    buildTextField(
                      label: student['father'],
                      icon: Icons.person_2,
                    ),
                    buildTextField(
                      label: student['address'],
                      icon: Icons.location_on,
                    ),
                    buildTextField(
                      label: student['password'],
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
