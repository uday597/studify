import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/leave.dart';
import 'package:studify/utils/appbar.dart';

class LeaveManager extends StatefulWidget {
  final int adminId;
  const LeaveManager({super.key, required this.adminId});

  @override
  State<LeaveManager> createState() => _LeaveManagerState();
}

class _LeaveManagerState extends State<LeaveManager> {
  bool isLoading = true;

  // map to hold controller for each leave id
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    final provider = Provider.of<LeaveManagerProvider>(context, listen: false);
    await provider.fetchLeaves(widget.adminId);
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    // dispose all controllers
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    _replyControllers.clear();
    super.dispose();
  }

  TextEditingController _controllerFor(String leaveId) {
    if (_replyControllers.containsKey(leaveId)) {
      return _replyControllers[leaveId]!;
    } else {
      final controller = TextEditingController();
      _replyControllers[leaveId] = controller;
      return controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeaveManagerProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: "Leave Manager"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.leaveRequests.isEmpty
          ? const Center(
              child: Text(
                "No Leave Requests Found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.leaveRequests.length,
              itemBuilder: (context, index) {
                final leave = provider.leaveRequests[index];
                // Ensure id exists and is a String
                final leaveId = leave['id'].toString();
                final replyController = _controllerFor(leaveId);

                // If you want to prefill controller from leave['admin_reply']
                if (replyController.text.isEmpty &&
                    (leave['admin_reply'] ?? '').toString().isNotEmpty) {
                  replyController.text = leave['admin_reply'].toString();
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              leave["role"] == "student"
                                  ? "Student Leave"
                                  : "Teacher Leave",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: leave["status"] == "approved"
                                    ? Colors.green.withOpacity(0.2)
                                    : leave["status"] == "rejected"
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                leave["status"].toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: leave["status"] == "approved"
                                      ? Colors.green
                                      : leave["status"] == "rejected"
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Reason
                        Text(
                          "Reason: ${leave["reason"]}",
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 6),

                        /// Date Range
                        Text(
                          "From: ${leave["from_date"]}  →  To: ${leave["to_date"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Reply input (per-item)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: replyController,
                            decoration: InputDecoration(
                              label: const Text('Reply (optional)'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                final replyText = replyController.text.trim();

                                // call provider: ensure provider.updateStatus accepts reply param
                                await provider.updateStatus(
                                  leaveId: leaveId,
                                  newStatus: "approved",
                                  reply: replyText,
                                );

                                // Optionally refresh list or update local UI
                                await provider.fetchLeaves(widget.adminId);
                              },
                              child: const Text(
                                "Approve",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                final replyText = replyController.text.trim();

                                await provider.updateStatus(
                                  leaveId: leaveId,
                                  newStatus: "rejected",
                                  reply: replyText,
                                );

                                await provider.fetchLeaves(widget.adminId);
                              },
                              child: const Text(
                                "Reject",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            /// Delete
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black54,
                              ),
                              onPressed: () async {
                                await provider.deleteLeave(leaveId);
                                // remove controller for deleted leave
                                _replyControllers[leaveId]?.dispose();
                                _replyControllers.remove(leaveId);
                                await provider.fetchLeaves(widget.adminId);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
