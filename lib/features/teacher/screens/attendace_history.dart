import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class TeacherHistoryScreen extends StatefulWidget {
  const TeacherHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TeacherHistoryScreen> createState() => _TeacherHistoryScreenState();
}

class _TeacherHistoryScreenState extends State<TeacherHistoryScreen> {
  Map<DateTime, String> _attendanceMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherLoginProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final teacherId = teacherProvider.teacherData?['id'].toString();

    return Scaffold(
      appBar: ReuseAppbar(name: 'Attendance Calendar'),
      backgroundColor: Colors.white,
      body: teacherId == null
          ? const Center(child: Text('Please login first'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: attendanceProvider.getTeacherAttendanceHistory(
                teacherId: teacherId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final history = snapshot.data ?? [];

                if (history.isEmpty) {
                  return const Center(
                    child: Text('No attendance records found'),
                  );
                }

                // Convert attendance data into map {DateTime: status}
                _attendanceMap = {
                  for (var record in history)
                    DateTime.parse(record['date']): record['status'].toString(),
                };

                return _buildCalendarView();
              },
            ),
    );
  }

  /// 🗓️ Calendar UI
  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final status = _attendanceMap[DateUtils.dateOnly(day)];
              if (status != null) {
                final color = _getStatusColor(status);
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        if (_selectedDay != null) _buildSelectedDayInfo(_selectedDay!),
      ],
    );
  }

  Widget _buildSelectedDayInfo(DateTime day) {
    final status = _attendanceMap[DateUtils.dateOnly(day)];
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(
            status == null
                ? Icons.info_outline
                : status.toLowerCase() == 'present'
                ? Icons.check_circle
                : Icons.cancel,
            color: status == null ? Colors.grey : _getStatusColor(status),
          ),
          title: Text(
            '${day.day}/${day.month}/${day.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            status == null ? 'No record for this day' : 'Status: $status',
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
