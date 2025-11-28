import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/admin/screens/behavior_rating.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/utils/appbar.dart';

class BehaviorStudentList extends StatefulWidget {
  final String batchId;
  final int adminId;

  const BehaviorStudentList({
    super.key,
    required this.batchId,
    required this.adminId,
  });

  @override
  State<BehaviorStudentList> createState() => _BehaviorStudentListState();
}

class _BehaviorStudentListState extends State<BehaviorStudentList> {
  @override
  void initState() {
    super.initState();
    context.read<StudentProvider>().fetchStudentsByBatch(
      widget.batchId,
      widget.adminId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: ReuseAppbar(name: 'Select Student'),
      backgroundColor: Colors.white,
      body: provider.StudentList.isEmpty
          ? const Center(child: Text("No students found"))
          : ListView.builder(
              itemCount: provider.StudentList.length,
              itemBuilder: (_, i) {
                final student = provider.StudentList[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(student['name']),
                  subtitle: Text(student['father']),
                  trailing: const Icon(Icons.star_rate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BehaviorRatingScreen(
                          studentId: student['id'],
                          batchId: widget.batchId,
                          adminId: widget.adminId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
