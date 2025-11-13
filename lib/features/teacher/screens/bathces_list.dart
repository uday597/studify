import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<BatchProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // full white background
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: batchProvider.batches.length,
                itemBuilder: (context, index) {
                  final batch = batchProvider.batches[index];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Batch icon with number
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Batch details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  batch['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        batch['location'] ?? 'No Location',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      batch['incharge'] ?? 'No Incharge',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
