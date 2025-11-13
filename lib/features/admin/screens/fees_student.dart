import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/features/admin/screens/student_fees.dart';
import 'package:studify/utils/appbar.dart';

class TutionFees extends StatefulWidget {
  const TutionFees({super.key});

  @override
  State<TutionFees> createState() => _TutionFeesState();
}

class _TutionFeesState extends State<TutionFees> {
  String? selectBatchId;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final adminProvider = Provider.of<AdminProfileProvider>(
      context,
      listen: false,
    );
    final batchProvider = Provider.of<BatchProvider>(context, listen: false);

    await adminProvider.ensureAdminLoaded();
    if (adminProvider.adminId != null) {
      await batchProvider.fetchData(adminId: adminProvider.adminId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProfileProvider>(context);
    final batchProvider = Provider.of<BatchProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Tuition Fees'),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Batch Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Batch',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              initialValue: selectBatchId,
              items: batchProvider.batches.map((batch) {
                return DropdownMenuItem<String>(
                  value: batch['id'].toString(),
                  child: Text(batch['name']),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  selectBatchId = value;
                });
                if (value != null) {
                  // 🔥 IMPROVED: Add admin check
                  await adminProvider.ensureAdminLoaded();
                  if (adminProvider.adminId != null) {
                    await studentProvider.fetchStudentsByBatch(
                      value,
                      adminProvider.adminId!,
                    );
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 10),

          // Students List
          if (selectBatchId == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Please select a batch to view students',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else if (studentProvider.StudentList.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No students found in this batch',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: studentProvider.StudentList.length,
                itemBuilder: (context, index) {
                  final student = studentProvider.StudentList[index];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          student['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        student['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(student['email'] ?? 'No email'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentFeesScreen(
                              student: student,
                              batchId: selectBatchId!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
