import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/teacher/screens/homework.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';

class TeacherBatchesScreen extends StatefulWidget {
  const TeacherBatchesScreen({super.key});

  @override
  State<TeacherBatchesScreen> createState() => _TeacherBatchesScreenState();
}

class _TeacherBatchesScreenState extends State<TeacherBatchesScreen> {
  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final teacherData = Provider.of<TeacherLoginProvider>(
      context,
      listen: false,
    ).teacherData;

    if (teacherData != null) {
      await context.read<BatchProvider>().fetchData(
        adminId: teacherData['admin_id'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<BatchProvider>();
    final teacherData = context.watch<TeacherLoginProvider>().teacherData;

    return Scaffold(
      appBar: ReuseAppbar(name: 'Batches'),
      backgroundColor: Colors.white,
      body: batchProvider.batches.isEmpty
          ? const Center(child: Text('No batches available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, index) {
                final batch = batchProvider.batches[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeworkListScreen(
                            batchId: batch['id'].toString(),
                            batchName: batch['name'] ?? 'Batch',
                            adminId: teacherData?['admin_id'] ?? 0,
                            teacherId: teacherData?['id'].toString() ?? '',
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(batch['name'] ?? 'No Name'),
                    subtitle: Text(batch['location'] ?? 'No Location'),
                    trailing: Text(batch['incharge'] ?? 'No Incharge'),
                  ),
                );
              },
            ),
    );
  }
}
