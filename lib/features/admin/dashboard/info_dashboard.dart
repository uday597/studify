import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/student.dart';

class InfoDashboard extends StatefulWidget {
  final int adminId;
  const InfoDashboard({super.key, required this.adminId});

  @override
  State<InfoDashboard> createState() => _InfoDashboardState();
}

class _InfoDashboardState extends State<InfoDashboard> {
  String? selectedBatch;

  Map<String, int> studentAttendanceStats = {
    'total': 0,
    'present': 0,
    'absent': 0,
    'leave': 0,
  };

  Map<String, int> teacherAttendanceStats = {
    'total': 0,
    'present': 0,
    'absent': 0,
    'leave': 0,
  };

  Map<String, int> monthlyTeacherStats = {
    'Present': 0,
    'Absent': 0,
    'Leave': 0,
  };

  List<Map<String, dynamic>> monthlyTeacherData = [];
  String selectedStatus = 'Present';
  List<Map<String, dynamic>> filteredTeachers = [];

  @override
  void initState() {
    super.initState();
    Provider.of<BatchProvider>(
      context,
      listen: false,
    ).fetchData(adminId: widget.adminId);
    fetchTeacherAttendance();
    fetchMonthlyTeacherAttendance();
  }

  Future<void> fetchTeacherAttendance() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    final teachersAttendance = await attendanceProvider.getTeacherAttendance(
      adminId: widget.adminId,
      date: DateTime.now(),
    );

    int present = 0, absent = 0, leave = 0;

    for (var att in teachersAttendance) {
      final status = att['status'];
      if (status == 'Present') present++;
      if (status == 'Absent') absent++;
      if (status == 'Leave') leave++;
    }

    setState(() {
      teacherAttendanceStats['total'] = teachersAttendance.length;
      teacherAttendanceStats['present'] = present;
      teacherAttendanceStats['absent'] = absent;
      teacherAttendanceStats['leave'] = leave;
    });
  }

  Future<void> fetchBatchAttendance(String batchId) async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    await studentProvider.fetchStudentsByBatch(batchId, widget.adminId);
    final students = studentProvider.StudentList;

    int present = 0, absent = 0, leave = 0;

    for (var student in students) {
      final studentId = student['id'];
      final attendance = await attendanceProvider.getStudentAttendance(
        adminId: widget.adminId,
        batchId: batchId,
        date: DateTime.now(),
      );

      final studentAttendance = attendance
          .where((att) => att['student_id'] == studentId)
          .toList();

      if (studentAttendance.isNotEmpty) {
        final status = studentAttendance.first['status'];
        if (status == 'Present') present++;
        if (status == 'Absent') absent++;
        if (status == 'Leave') leave++;
      }
    }

    setState(() {
      studentAttendanceStats['total'] = students.length;
      studentAttendanceStats['present'] = present;
      studentAttendanceStats['absent'] = absent;
      studentAttendanceStats['leave'] = leave;
    });
  }

  Future<void> fetchMonthlyTeacherAttendance() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    final data = await attendanceProvider.getTeacherAttendance(
      adminId: widget.adminId,
    );

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    int present = 0, absent = 0, leave = 0;
    List<Map<String, dynamic>> monthlyData = [];

    for (var att in data) {
      final date = DateTime.parse(att['date']);
      if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        if (att['status'] == 'Present') present++;
        if (att['status'] == 'Absent') absent++;
        if (att['status'] == 'Leave') leave++;

        monthlyData.add({
          'name': att['teachers']['name'] ?? 'Unknown',
          'date': att['date'],
          'status': att['status'],
        });
      }
    }

    setState(() {
      monthlyTeacherStats['Present'] = present;
      monthlyTeacherStats['Absent'] = absent;
      monthlyTeacherStats['Leave'] = leave;
      monthlyTeacherData = monthlyData;
    });

    filterTeachersByStatus('Present');
  }

  void filterTeachersByStatus(String status) {
    setState(() {
      selectedStatus = status;
      filteredTeachers = monthlyTeacherData
          .where((t) => t['status'] == status)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Quick Stats Row
              _buildQuickStats(),
              const SizedBox(height: 20),

              // Batch Selection
              _buildBatchSelector(batchProvider),
              const SizedBox(height: 16),

              // Student Attendance Card
              if (selectedBatch != null) ...[
                _buildStudentAttendanceCard(),
                const SizedBox(height: 20),
              ],

              // Monthly Teacher Attendance
              _buildMonthlyTeacherAttendance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Overview of today\'s attendance',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Teachers Today',
            total: teacherAttendanceStats['total'] ?? 0,
            present: teacherAttendanceStats['present'] ?? 0,
            absent: teacherAttendanceStats['absent'] ?? 0,
            leave: teacherAttendanceStats['leave'] ?? 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Students Today',
            total: studentAttendanceStats['total'] ?? 0,
            present: studentAttendanceStats['present'] ?? 0,
            absent: studentAttendanceStats['absent'] ?? 0,
            leave: studentAttendanceStats['leave'] ?? 0,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSelector(BatchProvider batchProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButton<String>(
        hint: const Text("Select Batch", style: TextStyle(fontSize: 14)),
        value: selectedBatch,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        items: batchProvider.batches
            .map(
              (batch) => DropdownMenuItem<String>(
                value: batch['id'],
                child: Text(
                  batch['name'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
            .toList(),
        onChanged: (value) async {
          if (value != null) {
            setState(() {
              selectedBatch = value;
              studentAttendanceStats = {
                'total': 0,
                'present': 0,
                'absent': 0,
                'leave': 0,
              };
            });
            await fetchBatchAttendance(value);
          }
        },
      ),
    );
  }

  Widget _buildStudentAttendanceCard() {
    return _AttendanceCard(
      title: 'Student Attendance',
      stats: studentAttendanceStats,
    );
  }

  Widget _buildMonthlyTeacherAttendance() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  "Monthly Teacher Stats - ${getCurrentMonthName()}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pie Chart
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildPieChartSections(),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: _buildLegend()),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Buttons
            _buildFilterButtons(),
            const SizedBox(height: 16),

            // Teacher List - Improved Design
            _buildTeacherList(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total =
        (monthlyTeacherStats['Present'] ?? 0) +
        (monthlyTeacherStats['Absent'] ?? 0) +
        (monthlyTeacherStats['Leave'] ?? 0);

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey,
          title: 'No Data',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }
    return [
      PieChartSectionData(
        value: (monthlyTeacherStats['Present'] ?? 0).toDouble(),
        color: Colors.green,
        title:
            '${((monthlyTeacherStats['Present'] ?? 0) / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (monthlyTeacherStats['Absent'] ?? 0).toDouble(),
        color: Colors.red,
        title:
            '${((monthlyTeacherStats['Absent'] ?? 0) / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (monthlyTeacherStats['Leave'] ?? 0).toDouble(),
        color: Colors.orange,
        title:
            '${((monthlyTeacherStats['Leave'] ?? 0) / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.green,
          text: 'Present',
          count: monthlyTeacherStats['Present'] ?? 0,
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: Colors.red,
          text: 'Absent',
          count: monthlyTeacherStats['Absent'] ?? 0,
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: Colors.orange,
          text: 'Leave',
          count: monthlyTeacherStats['Leave'] ?? 0,
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _FilterButton(
          label: 'Present',
          count: monthlyTeacherStats['Present'] ?? 0,
          color: Colors.green,
          isSelected: selectedStatus == 'Present',
          onTap: () => filterTeachersByStatus('Present'),
        ),
        _FilterButton(
          label: 'Absent',
          count: monthlyTeacherStats['Absent'] ?? 0,
          color: Colors.red,
          isSelected: selectedStatus == 'Absent',
          onTap: () => filterTeachersByStatus('Absent'),
        ),
        _FilterButton(
          label: 'Leave',
          count: monthlyTeacherStats['Leave'] ?? 0,
          color: Colors.orange,
          isSelected: selectedStatus == 'Leave',
          onTap: () => filterTeachersByStatus('Leave'),
        ),
      ],
    );
  }

  Widget _buildTeacherList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teachers ($selectedStatus) - ${filteredTeachers.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        if (filteredTeachers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No teachers found',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          )
        else
          // Improved Teacher List - Better Design
          Column(
            children: [
              // List Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Teacher Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Teacher List Items
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                constraints: const BoxConstraints(
                  maxHeight: 150, // Fixed height for better visibility
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final t = filteredTeachers[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: index < filteredTeachers.length - 1
                              ? BorderSide(color: Colors.grey[300]!)
                              : BorderSide.none,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        dense: true,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(t['status']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          t['name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Text(
                          t['date'].toString().split("T")[0],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getCurrentMonthName() {
    final now = DateTime.now();
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[now.month - 1];
  }
}

// ---------------- Reusable Widgets ----------------

class _StatCard extends StatelessWidget {
  final String title;
  final int total;
  final int present;
  final int absent;
  final int leave;

  const _StatCard({
    required this.title,
    required this.total,
    required this.present,
    required this.absent,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.groups,
                  size: 18,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: 'Total', value: total),
              _StatItem(label: 'Present', value: present),
              _StatItem(label: 'Absent', value: absent),
              _StatItem(label: 'Leave', value: leave),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String title;
  final Map<String, int> stats;

  const _AttendanceCard({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: title,
      total: stats['total'] ?? 0,
      present: stats['present'] ?? 0,
      absent: stats['absent'] ?? 0,
      leave: stats['leave'] ?? 0,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final int count;

  const _LegendItem({
    required this.color,
    required this.text,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
