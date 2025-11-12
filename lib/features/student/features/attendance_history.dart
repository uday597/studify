import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/utils/appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentAttendanceHistory extends StatefulWidget {
  const StudentAttendanceHistory({super.key});

  @override
  State<StudentAttendanceHistory> createState() =>
      _StudentAttendanceHistoryState();
}

class _StudentAttendanceHistoryState extends State<StudentAttendanceHistory> {
  Map<DateTime, String> _attendanceMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentAttendance();
  }

  Future<void> _loadStudentAttendance() async {
    final studentProvider = Provider.of<StudentLoginProvider>(
      context,
      listen: false,
    );
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final studentData = studentProvider.studentData;

    if (studentData == null ||
        studentData['id'] == null ||
        studentData['admin_id'] == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final history = await attendanceProvider.getStudentAttendanceHistory(
        studentId: studentData['id'].toString(),
        adminId: int.parse(studentData['admin_id'].toString()),
      );

      // Build date → status map
      final map = <DateTime, String>{};
      for (final record in history) {
        final dateStr = record['date'];
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          map[DateUtils.dateOnly(date)] = record['status'].toString();
        }
      }

      if (mounted) {
        setState(() {
          _attendanceMap = map;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading student attendance: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Attendance Calendar'),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceMap.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No attendance records found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildCalendarView(),
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
                    color: color.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

  /// 🟢 Show details for selected date
  Widget _buildSelectedDayInfo(DateTime day) {
    final status = _attendanceMap[DateUtils.dateOnly(day)];
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
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

  /// 🎨 Status color helper
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
