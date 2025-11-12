import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/features/admin/auth/signup.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  String gender = "Male";
  String? selectedBatchId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final adminProvider = Provider.of<AdminProfileProvider>(
        context,
        listen: false,
      );
      final batchProvider = Provider.of<BatchProvider>(context, listen: false);

      // 🔥 WAIT FOR ADMIN DATA
      adminProvider.ensureAdminLoaded().then((_) {
        if (adminProvider.adminId != null) {
          batchProvider.fetchData(adminId: adminProvider.adminId!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ReuseTextfield(
                controller: nameController,
                text: 'Student Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter student name' : null,
              ),
              ReuseTextfield(
                controller: emailController,
                text: 'Email',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter father name' : null,
              ),
              ReuseTextfield(
                controller: fatherController,
                text: 'Father Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter father name' : null,
              ),
              Row(
                children: [
                  const Text("Gender: "),
                  Radio<String>(
                    value: "Male",
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text("Male"),
                  Radio<String>(
                    value: "Female",
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text("Female"),
                  Radio<String>(
                    value: "Other",
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  const Text("Other"),
                ],
              ),
              ReuseTextfield(
                text: 'Password',
                controller: passwordcontroller,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter password' : null,
              ),
              ReuseTextfield(
                controller: mobileController,
                text: 'Mobile Number',
              ),

              ReuseTextfield(controller: addressController, text: 'Address'),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Batch'),
                value: selectedBatchId,
                items: batchProvider.batches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch['id'],
                    child: Text(batch['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedBatchId = val),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please select a batch' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // 🔥 GET ADMIN ID SAFELY
                      final adminProvider = Provider.of<AdminProfileProvider>(
                        context,
                        listen: false,
                      );
                      await adminProvider.ensureAdminLoaded();

                      if (adminProvider.adminId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Admin not logged in properly'),
                          ),
                        );
                        return;
                      }

                      await studentProvider.addStudentdata(
                        password: passwordcontroller.text,
                        name: nameController.text,
                        email: emailController.text,
                        father: fatherController.text,
                        gender: gender,
                        mobile: mobileController.text,
                        address: addressController.text,
                        batchId: selectedBatchId!,
                        adminId: adminProvider.adminId!, // ✅ SAFE NOW
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                child: const Text('Save Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
