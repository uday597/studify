import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/features/teacher.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/features/admin/screens/student_report.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class Reports extends StatefulWidget {
  final int adminId;
  const Reports({super.key, required this.adminId});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String? selectedBatchId;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<BatchProvider>(
      context,
      listen: false,
    ).fetchData(adminId: widget.adminId);

    Provider.of<TeacherProvider>(
      context,
      listen: false,
    ).fatchTeachers(adminId: widget.adminId);
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: "Reports"),
      backgroundColor: Colors.white,
      body: selectedTab == 0
          ? buildStudentReportTab(batchProvider, studentProvider)
          : buildTeacherReportTab(teacherProvider),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => selectedTab = 0),
                child: Text(
                  "Students",
                  style: TextStyle(
                    color: selectedTab == 0 ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => selectedTab = 1),
                child: Text(
                  "Teachers",
                  style: TextStyle(
                    color: selectedTab == 1 ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentReportTab(
    BatchProvider batchProvider,
    StudentProvider studentProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          batchProvider.loading
              ? CircularProgressIndicator()
              : DropdownButton<String>(
                  hint: Text("Select Batch"),
                  value: selectedBatchId,
                  isExpanded: true,
                  items: batchProvider.batches
                      .map<DropdownMenuItem<String>>(
                        (batch) => DropdownMenuItem<String>(
                          value: batch['id'] as String,
                          child: Text(batch['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    setState(() => selectedBatchId = value);
                    if (value != null) {
                      await studentProvider.fetchStudentsByBatch(
                        value,
                        widget.adminId,
                      );
                    }
                  },
                ),
          SizedBox(height: 16),
          Expanded(
            child: studentProvider.StudentList.isEmpty
                ? Center(child: Text("No students found"))
                : ListView.builder(
                    itemCount: studentProvider.StudentList.length,
                    itemBuilder: (context, index) {
                      final student = studentProvider.StudentList[index];
                      return ListTile(
                        title: Text(student['name']),
                        subtitle: Text(student['email'] ?? ''),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentReport(
                                adminId: widget.adminId,
                                studentId: student['id'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildTeacherReportTab(TeacherProvider teacherProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: teacherProvider.teachers.length,
        itemBuilder: (context, index) {
          final teacher = teacherProvider.teachers[index];

          return ListTile(
            title: Text(teacher['name']),
            subtitle: Text(teacher['email'] ?? ''),
            trailing: Icon(Icons.picture_as_pdf, color: Colors.red),
            onTap: () {
              showTeacherReportPopup(
                teacherId: teacher['id'],
                teacherName: teacher['name'],
              );
            },
          );
        },
      ),
    );
  }

  void showTeacherReportPopup({
    required String teacherId,
    required String teacherName,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Generate Report for $teacherName",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Generate Attendance Report"),
                onPressed: () {
                  Navigator.pop(context);
                  generateTeacherAttendanceReportFunction(
                    teacherId: teacherId,
                    teacherName: teacherName,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> generateTeacherAttendanceReportFunction({
    required String teacherId,
    required String teacherName,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final attendance = await provider.getTeacherAttendanceHistory(
        teacherId: teacherId,
      );

      final pdfBytes = await buildTeacherPDF(
        teacherName: teacherName,
        attendance: attendance,
      );

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$teacherName-Attendance.pdf");
      await file.writeAsBytes(pdfBytes);

      Navigator.pop(context);

      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<List<int>> buildTeacherPDF({
    required String teacherName,
    required List<Map<String, dynamic>> attendance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Teacher Attendance Report",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Teacher: $teacherName", style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ["Date", "Status"],
              data: attendance
                  .map((e) => [e["date"].toString(), e["status"].toString()])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
