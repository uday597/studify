import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/teacher.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/features/admin/auth/signup.dart';
import 'package:studify/features/admin/screens/teacher_profile.dart';
import 'package:studify/utils/appbar.dart';

class AddTeachers extends StatefulWidget {
  const AddTeachers({super.key});

  @override
  State<AddTeachers> createState() => _AddTeachersState();
}

class _AddTeachersState extends State<AddTeachers> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  String gender = "Male";

  @override
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final adminProvider = Provider.of<AdminProfileProvider>(
        context,
        listen: false,
      );
      final teacherProvider = Provider.of<TeacherProvider>(
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
    final adminProvider = Provider.of<AdminProfileProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Teachers'),
      backgroundColor: Colors.white,
      body: teacherProvider.teachers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: teacherProvider.teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teacherProvider.teachers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TeacherProfile(teacherData: teacher),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blueAccent,
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
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(teacher['email']),
                            const SizedBox(height: 4),
                            Text("Mobile: ${teacher['mobile']}"),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

      // ✅ Floating Action Button with Text + Icon
      floatingActionButton: SizedBox(
        width: 170,
        height: 50,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 22),
          label: const Text(
            'Add Teacher',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            _showAddTeacherDialog(context, teacherProvider, adminProvider);
          },
        ),
      ),
    );
  }

  void _showAddTeacherDialog(
    BuildContext context,
    TeacherProvider teacherProvider,
    AdminProfileProvider adminProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String localGender = gender;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- HEADER ----------
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  color: Colors.blueAccent,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Add New Teacher",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Fill the details below to add a new teacher",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // ---------- FORM FIELDS ----------
                        ReuseTextfield(
                          controller: nameController,
                          text: 'Full Name',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter teacher name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        ReuseTextfield(
                          controller: emailController,
                          text: 'Email Address',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 12),
                        ReuseTextfield(
                          controller: salaryController,
                          text: 'Salary',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter salary amount'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 0,
                            children: [
                              ChoiceChip(
                                label: const Text("Male"),
                                selected: localGender == "Male",
                                selectedColor: Colors.blueAccent,
                                labelStyle: TextStyle(
                                  color: localGender == "Male"
                                      ? Colors.white
                                      : Colors.black87,
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
                                      : Colors.black87,
                                ),
                                onSelected: (_) => setStateDialog(
                                  () => localGender = "Female",
                                ),
                              ),
                              ChoiceChip(
                                label: const Text("Other"),
                                selected: localGender == "Other",
                                selectedColor: Colors.purpleAccent,
                                labelStyle: TextStyle(
                                  color: localGender == "Other"
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                onSelected: (_) =>
                                    setStateDialog(() => localGender = "Other"),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        ReuseTextfield(
                          text: 'Password',
                          controller: passwordcontroller,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 12),
                        ReuseTextfield(
                          keyboardType: TextInputType.phone,
                          controller: mobileController,
                          text: 'Mobile Number',
                          validator: (v) {
                            final pattern = RegExp(r'^(?:\+91)?[6-9]\d{9}$');

                            if (!pattern.hasMatch(v!.trim())) {
                              return 'Enter valid mobile number (e.g. +919876543210 or 9876543210)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        ReuseTextfield(
                          controller: addressController,
                          text: 'Address',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter address' : null,
                        ),

                        const SizedBox(height: 28),

                        // ---------- BUTTONS ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Cancel Button
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  nameController.clear();
                                  emailController.clear();
                                  salaryController.clear();
                                  mobileController.clear();
                                  addressController.clear();
                                  passwordcontroller.clear();
                                  setState(() => gender = "Male");
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                label: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // Save Button
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                // In your AddTeachers screen, update the save button:
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      // 🔥 GET ADMIN ID SAFELY
                                      final adminProvider =
                                          Provider.of<AdminProfileProvider>(
                                            context,
                                            listen: false,
                                          );
                                      await adminProvider.ensureAdminLoaded();

                                      if (adminProvider.adminId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Admin not logged in properly',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      await teacherProvider.addTeacher(
                                        password: passwordcontroller.text,
                                        name: nameController.text,
                                        email: emailController.text,
                                        salary: salaryController.text,
                                        gender: localGender,
                                        mobile: mobileController.text,
                                        address: addressController.text,
                                        adminId: adminProvider
                                            .adminId!, // ✅ SAFE NOW
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Teacher added successfully!",
                                          ),
                                        ),
                                      );

                                      // Clear controllers and close dialog
                                      nameController.clear();
                                      emailController.clear();
                                      salaryController.clear();
                                      mobileController.clear();
                                      addressController.clear();
                                      passwordcontroller.clear();
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  "Save Teacher",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
