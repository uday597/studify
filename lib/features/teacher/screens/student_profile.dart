import 'package:flutter/material.dart';
import 'package:studify/utils/appbar.dart';

class TeacherStudentProfile extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const TeacherStudentProfile({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final student = studentData;

    return Scaffold(
      appBar: ReuseAppbar(name: 'Student Profile'),
      backgroundColor: Colors.white,
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
                    buildTextField(
                      label: _getSafeString(student['name']),
                      icon: Icons.person,
                    ),
                    buildTextField(
                      label: _getSafeString(student['email']),
                      icon: Icons.mail,
                    ),
                    buildTextField(
                      label: _getSafeString(student['mobile']),
                      icon: Icons.phone,
                    ),
                    buildTextField(
                      label: _getSafeString(student['father']),
                      icon: Icons.person_2,
                    ),
                    buildTextField(
                      label: _getSafeString(student['address']),
                      icon: Icons.location_on,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSafeString(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Not provided';
    return value.toString();
  }

  Widget buildTextField({required String label, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        enabled: false, // Read-only for teacher
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
