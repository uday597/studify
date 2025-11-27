import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/admin/screens/exam_manage.dart';
import 'package:studify/provider/admin/features/batch.dart';

class ExamBatchSelectionScreen extends StatefulWidget {
  final String userType;
  final String userId;
  final int adminId;

  const ExamBatchSelectionScreen({
    super.key,
    required this.userType,
    required this.userId,
    required this.adminId,
  });

  @override
  State<ExamBatchSelectionScreen> createState() =>
      _ExamBatchSelectionScreenState();
}

class _ExamBatchSelectionScreenState extends State<ExamBatchSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().fetchData(adminId: widget.adminId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Batch'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Consumer<BatchProvider>(
        builder: (context, batchProvider, child) {
          if (batchProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (batchProvider.batches.isEmpty) {
            return const Center(child: Text('No batches available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batchProvider.batches.length,
            itemBuilder: (context, index) {
              final batch = batchProvider.batches[index];
              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.class_, color: Colors.blue),
                  title: Text(
                    batch['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(batch['location'] ?? 'No Location'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamManagementScreen(
                          batchId: batch['id'],
                          batchName: batch['name'],
                          userType: widget.userType,
                          userId: widget.userId,
                          adminId: widget.adminId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
