import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/teacher/screens/student_list.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';

class BathcesList extends StatefulWidget {
  const BathcesList({super.key});

  @override
  State<BathcesList> createState() => _BathcesListState();
}

class _BathcesListState extends State<BathcesList> {
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

  void _openStudents(Map<String, dynamic> batch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BatchStudentList(batchId: batch['id'], batchName: batch['name']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<BatchProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ReuseAppbar(name: 'My Batches'),
      body: RefreshIndicator(
        onRefresh: _loadBatches,
        child: batchProvider.batches.isEmpty
            ? const Center(
                child: Text(
                  'No batches available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: batchProvider.batches.length,
                itemBuilder: (context, index) {
                  final batch = batchProvider.batches[index];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      title: Text(
                        batch['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  batch['location'] ?? 'No Location',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                batch['incharge'] ?? 'No Incharge',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _openStudents(batch),
                      ),
                      onTap: () => _openStudents(batch),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
