import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/admin/features/behavior.dart';
import 'package:studify/provider/student/quiz.dart';
import 'package:studify/utils/appbar.dart';

class StudentReport extends StatefulWidget {
  final int adminId;
  final String studentId;
  const StudentReport({
    super.key,
    required this.studentId,
    required this.adminId,
  });

  @override
  State<StudentReport> createState() => _StudentReportState();
}

class _StudentReportState extends State<StudentReport> {
  // COMMON SHARE FUNCTION
  Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  // COMMON TABLE ROW (Behavior Report)
  pw.TableRow tableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(title)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }

  Future<void> genrateBehaviourReport() async {
    print('starting...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<BehaviorProvider>(context, listen: false);
      await provider.fetchLatest(widget.studentId);
      Navigator.pop(context);

      if (provider.records.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No behavior records found')),
        );
        return;
      }

      final record = provider.records.first;
      final pdf = pw.Document();

      // ⭐ FIXED STAR FUNCTION
      String getStars(int value) {
        const filled = "★";
        const empty = "☆";
        return filled * value + empty * (5 - value);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "STUDENT BEHAVIOR REPORT",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      tableRow(
                        "Class Behavior",
                        getStars(record['class_behavior']),
                      ),
                      tableRow("Games", getStars(record['games'])),
                      tableRow("Homework", getStars(record['homework'])),
                      tableRow("Discipline", getStars(record['discipline'])),
                      tableRow(
                        "Communication",
                        getStars(record['communication']),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  pw.Text(
                    "Remarks:",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(record['remarks'] ?? "None"),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      // 🔵 DIRECT SHARE (No preview)
      await sharePdf(pdfBytes, "behavior_report.pdf");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error generating report")));
    }
  }

  Future<void> generateAttendanceReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final records = await provider.getMonthlyStudentAttendance(
        studentId: widget.studentId,
        adminId: widget.adminId,
      );

      Navigator.pop(context);

      if (records.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No attendance data found")),
        );
        return;
      }

      int present = 0, absent = 0, leave = 0;

      for (var r in records) {
        if (r['status'] == 'Present') present++;
        if (r['status'] == 'Absent') absent++;
        if (r['status'] == 'Leave') leave++;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Student Attendance Report",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Text("Summary:", style: pw.TextStyle(fontSize: 18)),
                  pw.Text("Present: $present"),
                  pw.Text("Absent: $absent"),
                  pw.Text("Leave: $leave"),

                  pw.SizedBox(height: 20),

                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              "Date",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              "Status",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...records.map(
                        (r) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(r['date']),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(r['status']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await sharePdf(pdfBytes, "attendance_report.pdf");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error generating report")));
    }
  }

  Future<void> generateQuizReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<StudentQuizProvider>(context, listen: false);

      final report = await provider.generateQuizReport(widget.studentId);

      Navigator.pop(context);

      if (report['attempts'].isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No quiz attempts found')));
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "STUDENT QUIZ REPORT",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Text(
                    "Summary:",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Total Quizzes Attempted: ${report['summary']['total_quizzes']}",
                  ),
                  pw.Text(
                    "Average Percentage: ${report['summary']['average_percentage']}%",
                  ),
                  pw.Text("Accuracy: ${report['summary']['accuracy']}%"),
                  pw.SizedBox(height: 20),

                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          tableHead("Quiz Title"),
                          tableHead("Batch"),
                          tableHead("Date"),
                          tableHead("Correct"),
                          tableHead("Percentage"),
                        ],
                      ),
                      ...report['attempts'].map<pw.TableRow>((attempt) {
                        return pw.TableRow(
                          children: [
                            tableCell(attempt['quiz_title']),
                            tableCell(attempt['batch']),
                            tableCell(attempt['date'].toString().split('T')[0]),
                            tableCell(
                              "${attempt['correct_answers']}/${attempt['total_questions']}",
                            ),
                            tableCell("${attempt['percentage']}%"),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await sharePdf(pdfBytes, "quiz_report.pdf");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating quiz report: $e")),
      );
    }
  }

  pw.Widget tableHead(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Generate Report'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          reuseButton(
            name: 'Attendance Report',
            bgcolor: Colors.red,
            ontap: generateAttendanceReport,
          ),
          reuseButton(
            name: 'Quiz Report',
            bgcolor: Colors.blue,
            ontap: generateQuizReport,
          ),
          reuseButton(
            name: 'Behavior Report',
            bgcolor: Colors.green,
            ontap: genrateBehaviourReport,
          ),
        ],
      ),
    );
  }

  Widget reuseButton({
    required String name,
    required Color bgcolor,
    VoidCallback? ontap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: ElevatedButton(
          onPressed: ontap,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(250, 50),
            backgroundColor: bgcolor,
            foregroundColor: Colors.white,
          ),
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
