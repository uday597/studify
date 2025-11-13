import 'package:flutter/material.dart';
import 'package:studify/features/admin/auth/login.dart';
import 'package:studify/features/admin/auth/signup.dart';
import 'package:studify/features/admin/dashboard/dashboard.dart';
import 'package:studify/features/admin/screens/batches.dart';
import 'package:studify/features/admin/screens/contact.dart';
import 'package:studify/features/admin/screens/notification.dart';
import 'package:studify/features/admin/screens/students.dart';
import 'package:studify/features/admin/screens/addteachers.dart';
import 'package:studify/features/admin/screens/fees_student.dart';
import 'package:studify/features/admin/profile/adminprofile.dart';
import 'package:studify/features/rolescreen/rolescreen.dart';
import 'package:studify/features/splashscreen/splashscreen.dart';
import 'package:studify/features/student/features/acd_info.dart';
import 'package:studify/features/student/features/attendance_history.dart';
import 'package:studify/features/student/features/batch_info.dart';
import 'package:studify/features/student/features/fees_history.dart';
import 'package:studify/features/student/login.dart';
import 'package:studify/features/teacher/screens/academy_info.dart';
import 'package:studify/features/teacher/screens/attendace_history.dart';
import 'package:studify/features/teacher/screens/batch_details.dart';
import 'package:studify/features/teacher/screens/bathces_list.dart';
import 'package:studify/features/teacher/teacher_login.dart';

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
    '/teacher_attendacne_history': (context) => TeacherHistoryScreen(),
    '/teacheracademyinfo': (context) => TeacherAcademyInfo(),
    '/teacherbatches': (context) => TeacherBatchesScreen(),
    '/batcheslist': (context) => BathcesList(),
    '/contactsupport': (context) => ContactUs(),
    '/notifications': (context) => NotificationScreen(),
  };
}
