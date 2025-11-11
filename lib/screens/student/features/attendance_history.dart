import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/utils/appbar.dart';

class StudentAttendanceHistory extends StatefulWidget {
  const StudentAttendanceHistory({super.key});

  @override
  State<StudentAttendanceHistory> createState() =>
      _StudentAttendanceHistoryState();
}

class _StudentAttendanceHistoryState extends State<StudentAttendanceHistory> {
  List<Map<String, dynamic>> attendanceHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    final studentProvider = Provider.of<StudentLoginProvider>(
      context,
      listen: false,
    );
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    try {
      final studentData = studentProvider.studentData;

      if (studentData != null &&
          studentData['id'] != null &&
          studentData['admin_id'] != null) {
        final history = await attendanceProvider.getStudentAttendanceHistory(
          studentId: studentData['id'].toString(),
          adminId: int.parse(studentData['admin_id'].toString()),
        );

        if (mounted) {
          setState(() {
            attendanceHistory = history;
            isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Attendance History'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Attendance Records',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final record = attendanceHistory[index];
                return _buildAttendanceCard(record);
              },
            ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final status = record['status'] ?? 'Unknown';
    final date = record['date'] ?? 'N/A';
    final time = record['submission_time'] ?? 'N/A';

    Color statusColor = Colors.grey;

    switch (status) {
      case 'Present':
        statusColor = Colors.green;
        break;
      case 'Absent':
        statusColor = Colors.red;
        break;
      case 'Leave':
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: statusColor),
        title: Text('Date: $date'),
        subtitle: Text('Time: $time'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
