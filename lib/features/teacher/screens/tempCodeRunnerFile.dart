import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';

class TeacherHistoryScreen extends StatelessWidget {
  const TeacherHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherLoginProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final teacherId = teacherProvider.teacherData?['id'].toString();

    return Scaffold(
      appBar: ReuseAppbar(name: 'Attendance History'),
      body: teacherId == null
          ? const Center(child: Text('Please login first'))
          : _buildHistoryList(attendanceProvider, teacherId),
    );
  }

  Widget _buildHistoryList(AttendanceProvider provider, String teacherId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getTeacherAttendanceHistory(teacherId: teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final history = snapshot.data!;

        if (history.isEmpty) {
          return const Center(child: Text('No attendance records found'));
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final record = history[index];
            return _buildAttendanceCard(record);
          },
        );
      },
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final date = DateTime.parse(record['date']);
    final createdAt = DateTime.parse(record['created_at']);
    final status = record['status'];
    final isPresent = status.toString().toLowerCase() == 'present';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(
          isPresent ? Icons.check_circle : Icons.cancel,
          color: isPresent ? Colors.green : Colors.red,
        ),
        title: Text(
          'Date: ${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Time: ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
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
