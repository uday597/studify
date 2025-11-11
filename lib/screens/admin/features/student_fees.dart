import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/fees.dart';
import 'package:studify/provider/admin/profile.dart';

class StudentFeesScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final String batchId;

  const StudentFeesScreen({
    super.key,
    required this.student,
    required this.batchId,
  });

  @override
  State<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends State<StudentFeesScreen> {
  List<Map<String, dynamic>> studentFees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentFees();
  }

  Future<void> _loadStudentFees() async {
    final adminProvider = Provider.of<AdminProfileProvider>(
      context,
      listen: false,
    );
    final feesProvider = Provider.of<FeesProvider>(context, listen: false);

    try {
      final fees = await feesProvider.getStudentFees(
        studentId: widget.student['id'],
        adminId: adminProvider.adminId!,
      );
      setState(() {
        studentFees = fees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading fees: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fees - ${widget.student['name']}'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Student Info Card
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 25,
                            child: Text(
                              widget.student['name'][0].toUpperCase(),
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
                                  widget.student['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.student['email'] ?? 'No email',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mobile: ${widget.student['mobile'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddFeeDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Fee'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showFeeHistory(),
                          icon: const Icon(Icons.history),
                          label: const Text('View History'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Fees List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fee Records',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          'Total: ${studentFees.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Fees List
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
                                  'Tap "Add New Fee" to add fees',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadStudentFees,
                            child: ListView.builder(
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
            ),
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> fee) {
    final isPaid = fee['status'] == 'Paid';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
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
          '₹${fee['amount']}',
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
              'Date: ${fee['submission_date']} • Time: ${fee['submission_time']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showUpdateFeeDialog(fee),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFee(fee['id']),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFeeDialog() {
    final TextEditingController amountController = TextEditingController();
    String selectedStatus = 'Pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.money, color: Colors.green),
                SizedBox(width: 8),
                Text('Add New Fee'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['Pending', 'Paid'].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter amount')),
                    );
                    return;
                  }

                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter valid amount'),
                      ),
                    );
                    return;
                  }

                  final adminProvider = Provider.of<AdminProfileProvider>(
                    context,
                    listen: false,
                  );
                  final feesProvider = Provider.of<FeesProvider>(
                    context,
                    listen: false,
                  );

                  try {
                    await feesProvider.addFee(
                      studentId: widget.student['id'],
                      batchId: widget.batchId,
                      amount: amount,
                      adminId: adminProvider.adminId!,
                    );

                    Navigator.pop(context);
                    await _loadStudentFees(); // Refresh list

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fee of ₹$amount added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding fee: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Add Fee',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateFeeDialog(Map<String, dynamic> fee) {
    final TextEditingController amountController = TextEditingController(
      text: fee['amount'].toString(),
    );
    String selectedStatus = fee['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Update Fee'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['Pending', 'Paid'].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter amount')),
                    );
                    return;
                  }

                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter valid amount'),
                      ),
                    );
                    return;
                  }

                  final adminProvider = Provider.of<AdminProfileProvider>(
                    context,
                    listen: false,
                  );
                  final feesProvider = Provider.of<FeesProvider>(
                    context,
                    listen: false,
                  );

                  try {
                    await feesProvider.updateFee(
                      feeId: fee['id'],
                      adminId: adminProvider.adminId!,
                      status: selectedStatus,
                      amount: amount,
                    );

                    Navigator.pop(context);
                    await _loadStudentFees(); // Refresh list

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fee updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating fee: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Update Fee',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFeeHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.purple),
            SizedBox(width: 8),
            Text('Fee History'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: studentFees.isEmpty
              ? const Center(
                  child: Text(
                    'No fee history found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: studentFees.length,
                  itemBuilder: (context, index) {
                    final fee = studentFees[index];
                    final isPaid = fee['status'] == 'Paid';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          isPaid ? Icons.check_circle : Icons.pending,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          '₹${fee['amount']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${fee['status']}'),
                            Text('Date: ${fee['submission_date']}'),
                            Text('Time: ${fee['submission_time']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFee(String feeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee'),
        content: const Text('Are you sure you want to delete this fee record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminProvider = Provider.of<AdminProfileProvider>(
        context,
        listen: false,
      );
      final feesProvider = Provider.of<FeesProvider>(context, listen: false);

      try {
        await feesProvider.deleteFee(feeId, adminProvider.adminId!);
        await _loadStudentFees(); // Refresh list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fee deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting fee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
