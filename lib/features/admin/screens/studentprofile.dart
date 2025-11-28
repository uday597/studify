import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/utils/appbar.dart';

class StudentProfile extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentProfile({super.key, required this.studentData});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProfileProvider>(context);
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final student = widget.studentData;

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
                    buildTextField(
                      label: _getSafeString(student['name']),
                      icon: Icons.person,
                    ),
                    buildTextField(
                      label: _getSafeString(student['rollno']),
                      icon: Icons.numbers,
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
                    buildTextField(
                      label: _getSafeString(student['password']),
                      icon: Icons.password,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _showEditDialog(
                              context,
                              provider,
                              student,
                              adminProvider,
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Student'),
                                content: const Text(
                                  'Are you sure you want to delete this student?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true &&
                                adminProvider.adminId != null) {
                              await provider.deleteStudent(
                                student['id'].toString(),
                                _getSafeString(
                                  student['batch_id'],
                                ), // Safe access
                                adminProvider.adminId!,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Student deleted successfully ✅',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
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
    if (value == null) return 'Not provided';
    return value.toString();
  }

  void _showEditDialog(
    BuildContext context,
    StudentProvider provider,
    Map<String, dynamic> student,
    AdminProfileProvider adminProvider,
  ) {
    final nameController = TextEditingController(
      text: _getSafeString(student['name']),
    );
    final rollnocontroller = TextEditingController(
      text: _getSafeString(student['rollno']),
    );
    final emailController = TextEditingController(
      text: _getSafeString(student['email']),
    );
    final fatherController = TextEditingController(
      text: _getSafeString(student['father']),
    );
    final mobileController = TextEditingController(
      text: _getSafeString(student['mobile']),
    );
    final addressController = TextEditingController(
      text: _getSafeString(student['address']),
    );
    final passwordController = TextEditingController(
      text: _getSafeString(student['password']),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(child: Text('Edit Student Details')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _dialogTextField(nameController, 'Name'),
              _dialogTextField(emailController, 'Email'),
              _dialogTextField(rollnocontroller, 'rollno'),
              _dialogTextField(fatherController, 'Father Name'),
              _dialogTextField(mobileController, 'Mobile'),
              _dialogTextField(addressController, 'Address'),
              _dialogTextField(passwordController, 'Password'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (adminProvider.adminId == null) return;

              try {
                await provider.updateStudentdata(
                  id: _getSafeString(student['id']),
                  name: nameController.text,
                  rollno: rollnocontroller.text,
                  email: emailController.text,
                  father: fatherController.text,
                  gender: _getSafeString(student['gender']),
                  mobile: mobileController.text,
                  address: addressController.text,
                  password: passwordController.text,
                  batchId: _getSafeString(student['batch_id']),
                  adminId: adminProvider.adminId!,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student updated successfully ✅'),
                  ),
                );
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildTextField({required String label, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        enabled: false,
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
