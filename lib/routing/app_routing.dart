import 'package:flutter/material.dart';
import 'package:studify/screens/admin/auth/login.dart';
import 'package:studify/screens/admin/auth/signup.dart';
import 'package:studify/screens/admin/dashboard/dashboard.dart';
import 'package:studify/screens/admin/features/batches.dart';
import 'package:studify/screens/admin/features/students.dart';
import 'package:studify/screens/admin/features/addteachers.dart';
import 'package:studify/screens/admin/features/fees_student.dart';
import 'package:studify/screens/admin/profile/adminprofile.dart';
import 'package:studify/screens/rolescreen/rolescreen.dart';
import 'package:studify/screens/splashscreen/splashscreen.dart';
import 'package:studify/screens/student/features/acd_info.dart';
import 'package:studify/screens/student/features/attendance_history.dart';
import 'package:studify/screens/student/features/batch_info.dart';
import 'package:studify/screens/student/features/fees_history.dart';
import 'package:studify/screens/student/login.dart';
import 'package:studify/screens/teacher/features/batch_info.dart';
import 'package:studify/screens/teacher/teacher_login.dart';

class AppRouting {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => Splashscreen(),
    '/rolescreen': (context) => RoleScreen(),
    '/adminlogin': (context) => AdminLogin(),
    '/adminsingup': (context) => AdminSignUp(),
    '/admindashboard': (context) => AdminDashboard(),
    '/adminprofile': (context) => Adminprofile(),
    '/adminbatch': (context) => Batches(),
    '/adminstudents': (context) => AddStudentScreen(),
    '/studentlogin': (context) => StudentLogin(),
    '/addteacher': (context) => AddTeachers(),
    '/teacherlogin': (context) => TeacherLogin(),
    '/tutionfees': (context) => TutionFees(),
    '/feeshistory': (context) => StudentFeesHistory(),
    '/batchinfo': (context) => BatchInfo(),
    '/academyinfo': (context) => AcademyInfo(),
    '/studentattendancehistory': (context) => StudentAttendanceHistory(),
    '/teacherbatchinfo': (context) => TeacherBatchDetails(),
  };
}
