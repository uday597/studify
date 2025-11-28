import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/leave.dart';
import 'package:studify/utils/appbar.dart';

class StudentLeave extends StatefulWidget {
  final int adminId;
  final String studentId;

  const StudentLeave({
    super.key,
    required this.adminId,
    required this.studentId,
  });

  @override
  State<StudentLeave> createState() => _StudentLeaveState();
}

class _StudentLeaveState extends State<StudentLeave> {
  final reasonController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => fromDate = picked);
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  void initState() {
    super.initState();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    final provider = Provider.of<LeaveManagerProvider>(context, listen: false);

    await provider.fetchLeavesRole(widget.adminId, userId: widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeaveManagerProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Leave Request'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // FROM DATE
                    buildDatePickerTile(
                      label: "From Date",
                      date: fromDate,
                      onTap: pickFromDate,
                    ),
                    const SizedBox(height: 16),

                    // TO DATE
                    buildDatePickerTile(
                      label: "To Date",
                      date: toDate,
                      onTap: pickToDate,
                    ),
                    const SizedBox(height: 20),

                    // Reason
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Reason for Leave",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (fromDate == null || toDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select dates"),
                              ),
                            );
                            return;
                          }

                          if (reasonController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enter a reason")),
                            );
                            return;
                          }

                          await Provider.of<LeaveManagerProvider>(
                            context,
                            listen: false,
                          ).addLeave(
                            userId: widget.studentId,
                            role: "student",
                            reason: reasonController.text.trim(),
                            fromDate: fromDate!,
                            toDate: toDate!,
                            adminId: widget.adminId,
                          );

                          // CLEAR FIELDS AFTER SUBMIT
                          reasonController.clear();
                          fromDate = null;
                          toDate = null;
                          setState(() {});

                          // REFRESH LIST INSTANTLY
                          await provider.fetchLeavesRole(
                            widget.adminId,
                            userId: widget.studentId,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Leave Request Submitted"),
                            ),
                          );
                        },
                        child: const Text(
                          "Submit Request",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Your Leave Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...provider.leaveRequests.map((leave) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    "Status: ${leave['status'] ?? 'pending'}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: leave['status'] == 'approved'
                          ? Colors.green
                          : leave['status'] == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Admin Reply: ${leave['admin_reply'] ?? 'Not replied yet'}",
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

Widget buildDatePickerTile({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 12),
          Text(
            date == null ? label : date.toString().split(" ")[0],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
