import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/teacher.dart';
import 'package:studify/provider/admin/profile.dart';

class TeacherProfile extends StatefulWidget {
  final Map<String, dynamic> teacherData;
  const TeacherProfile({super.key, required this.teacherData});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  @override
  Widget build(BuildContext context) {
    final teacher = widget.teacherData;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Teacher Profile",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- PROFILE HEADER ----------
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueAccent,
              child: Text(
                teacher['name'][0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- DETAILS SECTION ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    teacher['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    teacher['email'] ?? 'N/A',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      teacher['gender'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: teacher['gender'] == 'Male'
                        ? Colors.blueAccent
                        : teacher['gender'] == 'Female'
                        ? Colors.pinkAccent
                        : Colors.purpleAccent,
                  ),
                  _buildDetailRow(Icons.person, "Name", teacher['name']),
                  const Divider(),
                  _buildDetailRow(Icons.mail, "Email", teacher['email']),
                  const Divider(),
                  _buildDetailRow(Icons.female, "gender", teacher['gender']),
                  const Divider(),
                  _buildDetailRow(Icons.phone, "Mobile", teacher['mobile']),
                  const Divider(),
                  _buildDetailRow(
                    Icons.location_on,
                    "Address",
                    teacher['address'],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.attach_money,
                    "Salary",
                    teacher['salary'],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.lock_outline,
                    "Password",
                    teacher['password'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showEditTeacherDialog(context, teacher);
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- DETAIL ROW ----------
  Widget _buildDetailRow(IconData icon, String title, String? value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Icon(icon, color: Colors.blueAccent, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value ?? 'N/A',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- EDIT PROFILE DIALOG ----------
  // ---------- EDIT PROFILE DIALOG ----------
  void _showEditTeacherDialog(
    BuildContext context,
    Map<String, dynamic> teacher,
  ) {
    final nameController = TextEditingController(text: teacher['name']);
    final emailController = TextEditingController(text: teacher['email']);
    final mobileController = TextEditingController(text: teacher['mobile']);
    final addressController = TextEditingController(text: teacher['address']);
    final salaryController = TextEditingController(text: teacher['salary']);
    final passwordController = TextEditingController(text: teacher['password']);
    String localGender = teacher['gender'] ?? 'Male';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Edit Teacher Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField("Full Name", nameController),
                    _buildTextField("Email", emailController),
                    _buildTextField("Mobile", mobileController),
                    _buildTextField("Address", addressController),
                    _buildTextField("Salary", salaryController),
                    _buildTextField("Password", passwordController),

                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Male"),
                          selected: localGender == "Male",
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(
                            color: localGender == "Male"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) =>
                              setStateDialog(() => localGender = "Male"),
                        ),
                        ChoiceChip(
                          label: const Text("Female"),
                          selected: localGender == "Female",
                          selectedColor: Colors.pinkAccent,
                          labelStyle: TextStyle(
                            color: localGender == "Female"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) =>
                              setStateDialog(() => localGender = "Female"),
                        ),
                        ChoiceChip(
                          label: const Text("Other"),
                          selected: localGender == "Other",
                          selectedColor: Colors.purpleAccent,
                          labelStyle: TextStyle(
                            color: localGender == "Other"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) =>
                              setStateDialog(() => localGender = "Other"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              try {
                                final teacherProvider =
                                    Provider.of<TeacherProvider>(
                                      context,
                                      listen: false,
                                    );
                                final adminProvider =
                                    Provider.of<AdminProfileProvider>(
                                      context,
                                      listen: false,
                                    );

                                await adminProvider.ensureAdminLoaded();

                                if (adminProvider.adminId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Admin not logged in properly',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Call update method from TeacherProvider
                                await teacherProvider.updateTeacher(
                                  id: teacher['id'].toString(),
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  salary: salaryController.text.trim(),
                                  gender: localGender,
                                  mobile: mobileController.text.trim(),
                                  address: addressController.text.trim(),
                                  password: passwordController.text.trim(),
                                  adminId: adminProvider.adminId!,
                                );

                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Profile updated successfully!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Refresh the UI
                                setState(() {});
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error updating profile: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
