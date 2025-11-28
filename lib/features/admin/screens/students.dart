import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/features/admin/auth/signup.dart';
import 'package:studify/utils/appbar.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollnocontroller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController locationcontroller = TextEditingController();
  final TextEditingController inchargecontroller = TextEditingController();
  final TextEditingController batchController = TextEditingController();

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
      appBar: ReuseAppbar(name: 'Add Student'),
      backgroundColor: Colors.white,
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
                controller: nameController,
                text: 'Student Roll No',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter student roll no' : null,
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                keyboardType: TextInputType.phone,
                controller: mobileController,
                text: 'Mobile Number',
              ),

              ReuseTextfield(controller: addressController, text: 'Address'),

              const SizedBox(height: 12),

              batchProvider.batches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "No batches available",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Please add a new batch to continue.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddBatchPopup(context),
                                icon: const Icon(Icons.add),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                label: const Text(
                                  "Add New Batch",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Batch',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: selectedBatchId,
                        items: batchProvider.batches.map((batch) {
                          return DropdownMenuItem<String>(
                            value: batch['id'],
                            child: Text(batch['name']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedBatchId = val),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please select a batch'
                            : null,
                      ),
                    ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
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
                        rollno: rollnocontroller.text,
                        password: passwordcontroller.text,
                        name: nameController.text,
                        email: emailController.text,
                        father: fatherController.text,
                        gender: gender,
                        mobile: mobileController.text,
                        address: addressController.text,
                        batchId: selectedBatchId!,
                        adminId: adminProvider.adminId!,
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

  void _showAddBatchPopup(BuildContext context) {
    final provider = Provider.of<BatchProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProfileProvider>(
      context,
      listen: false,
    );

    final _batchFormKey = GlobalKey<FormState>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController inchargeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'New Batch',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        content: Form(
          key: _batchFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReuseTextfield(
                  controller: nameController,
                  text: 'Batch Name',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter batch name' : null,
                ),
                ReuseTextfield(
                  controller: locationController,
                  text: 'Batch Location',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter location' : null,
                ),
                ReuseTextfield(
                  controller: inchargeController,
                  text: 'Incharge Name',
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter incharge name'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_batchFormKey.currentState!.validate()) {
                try {
                  await adminProvider.ensureAdminLoaded();

                  if (adminProvider.adminId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin not logged in properly')),
                    );
                    return;
                  }

                  bool exists = await provider.checkBatchExists(
                    nameController.text.trim(),
                    adminProvider.adminId!,
                  );

                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Batch already exists')),
                    );
                    return;
                  }

                  await provider.addBatch(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    incharge: inchargeController.text.trim(),
                    adminId: adminProvider.adminId!,
                  );

                  Navigator.pop(context);

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Batch added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
