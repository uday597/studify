import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/admin/screens/behavior_studentlist.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/utils/appbar.dart';

class BehaviorBatchSelection extends StatefulWidget {
  final int adminId;
  const BehaviorBatchSelection({super.key, required this.adminId});

  @override
  State<BehaviorBatchSelection> createState() => _BehaviorBatchSelectionState();
}

class _BehaviorBatchSelectionState extends State<BehaviorBatchSelection> {
  @override
  void initState() {
    super.initState();
    context.read<BatchProvider>().fetchData(adminId: widget.adminId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BatchProvider>();

    return Scaffold(
      appBar: ReuseAppbar(name: 'Select Batch'),
      backgroundColor: Colors.white,
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.batches.length,
              itemBuilder: (_, i) {
                final batch = provider.batches[i];
                return ListTile(
                  title: Text(batch['name']),
                  subtitle: Text(batch['location']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BehaviorStudentList(
                          batchId: batch['id'],
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
