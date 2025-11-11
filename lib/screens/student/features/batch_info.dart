import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/utils/appbar.dart';

class BatchInfo extends StatefulWidget {
  const BatchInfo({super.key});

  @override
  State<BatchInfo> createState() => _BatchInfoState();
}

class _BatchInfoState extends State<BatchInfo> {
  Map<String, dynamic>? batchData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatchData();
  }

  Future<void> _loadBatchData() async {
    final studentProvider = Provider.of<StudentLoginProvider>(
      context,
      listen: false,
    );
    final batchProvider = Provider.of<BatchProvider>(context, listen: false);

    try {
      final studentData = studentProvider.studentData;

      if (studentData != null && studentData['batch_id'] != null) {
        final batchId = studentData['batch_id'].toString();

        // Fetch all batches for the admin
        await batchProvider.fetchData(
          adminId: int.parse(studentData['admin_id'].toString()),
        );

        // Find the specific batch for this student
        final batch = batchProvider.batches.firstWhere(
          (b) => b['id'].toString() == batchId,
          orElse: () => {},
        );

        setState(() {
          batchData = batch.isNotEmpty ? batch : null;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading batch data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentLoginProvider>(context);
    final studentData = studentProvider.studentData ?? {};

    return Scaffold(
      appBar: ReuseAppbar(name: 'Batch Information'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : batchData == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Batch Assigned',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You are not assigned to any batch',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildBatchContent(studentData),
    );
  }

  Widget _buildBatchContent(Map<String, dynamic> studentData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            color: Colors.lightBlue,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/stulogo.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    batchData!['name'] ?? 'Unknown Batch',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    batchData!['location'] ?? 'No Location',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.person,
                    title: 'Batch Incharge',
                    value: batchData!['incharge'] ?? 'Not Assigned',
                  ),

                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.location_on,
                    title: 'Location',
                    value: batchData!['location'] ?? 'Not Specified',
                  ),

                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    title: 'Batch ID',
                    value:
                        batchData!['id']?.toString().substring(0, 8) ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Student Information Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.person,
                    title: 'Student Name',
                    value: studentData['name'] ?? 'Unknown',
                  ),

                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.email,
                    title: 'Email',
                    value: studentData['email'] ?? 'Not Provided',
                  ),

                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.phone,
                    title: 'Mobile',
                    value: studentData['mobile'] ?? 'Not Provided',
                  ),

                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.family_restroom,
                    title: "Father's Name",
                    value: studentData['father'] ?? 'Not Provided',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Additional Information
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are enrolled in ${batchData!['name']} batch located at ${batchData!['location']}. '
                    'Your batch incharge is ${batchData!['incharge']}. '
                    'For any queries related to your batch, please contact your batch incharge.',
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
