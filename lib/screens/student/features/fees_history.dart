import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/provider/admin/features/fees.dart';
import 'package:studify/utils/appbar.dart';

class StudentFeesHistory extends StatefulWidget {
  const StudentFeesHistory({super.key});

  @override
  State<StudentFeesHistory> createState() => _StudentFeesHistoryState();
}

class _StudentFeesHistoryState extends State<StudentFeesHistory> {
  List<Map<String, dynamic>> studentFees = [];
  bool isLoading = true;
  double totalPaid = 0;
  double totalPending = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentFees();
  }

  Future<void> _loadStudentFees() async {
    final studentProvider = Provider.of<StudentLoginProvider>(
      context,
      listen: false,
    );
    final feesProvider = Provider.of<FeesProvider>(context, listen: false);

    try {
      // Get student data from provider
      final studentData = studentProvider.studentData;

      if (studentData != null &&
          studentData['id'] != null &&
          studentData['admin_id'] != null) {
        final fees = await feesProvider.getStudentFees(
          studentId: studentData['id'].toString(),
          adminId: int.parse(studentData['admin_id'].toString()),
        );

        // Calculate totals
        double paid = 0;
        double pending = 0;

        for (var fee in fees) {
          if (fee['status'] == 'Paid') {
            paid += (fee['amount'] ?? 0).toDouble();
          } else {
            pending += (fee['amount'] ?? 0).toDouble();
          }
        }

        setState(() {
          studentFees = fees;
          totalPaid = paid;
          totalPending = pending;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student data not available. Please login again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading fees: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentLoginProvider>(context);
    final studentData = studentProvider.studentData ?? {};

    return Scaffold(
      appBar: ReuseAppbar(name: 'My Fees History'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Student Info Card
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 25,
                          child: Text(
                            _getInitial(studentData['name']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentData['name']?.toString() ?? 'Student',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                studentData['email']?.toString() ?? 'No email',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Fee History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: studentFees.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No fees records found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your fee history will appear here',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadStudentFees,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: studentFees.length,
                            itemBuilder: (context, index) {
                              final fee = studentFees[index];
                              return _buildFeeCard(fee);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> fee) {
    final isPaid = fee['status'] == 'Paid';
    final amount = fee['amount'] ?? 0;
    final date = fee['submission_date'] ?? 'N/A';
    final time = fee['submission_time'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPaid
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Status: ${fee['status']}',
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Date: $date',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Time: $time',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPaid ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            fee['status']?.toString() ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get safe initial
  String _getInitial(dynamic name) {
    if (name == null || name.toString().isEmpty) return 'S';
    return name.toString()[0].toUpperCase();
  }
}
