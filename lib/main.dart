import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/attendance.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/features/behavior.dart';
import 'package:studify/provider/admin/features/fees.dart';
import 'package:studify/provider/admin/features/leave.dart';
import 'package:studify/provider/admin/features/student.dart';
import 'package:studify/provider/admin/features/teacher.dart';
import 'package:studify/provider/admin/features/todo.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/provider/exam.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/provider/quiz_teacher&admin.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/provider/student/quiz.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/routing/app_routing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlhbWpwZ3FzY2R1c2FicnRhdWl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNzAxMTYsImV4cCI6MjA3Nzc0NjExNn0.y2th-Yq--fGgGbG5Sn0rB8_DmRBBGKYVpEr3ViLZv3M',
    url: 'https://iamjpgqscdusabrtauiw.supabase.co',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeaveManagerProvider()),

        ChangeNotifierProvider(create: (_) => BehaviorProvider()),
        ChangeNotifierProvider(create: (_) => ExamsProvider()),
        ChangeNotifierProvider(create: (_) => ToDoProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => StudentQuizProvider()),
        ChangeNotifierProvider(create: (_) => HomeworkProvider()),
        ChangeNotifierProvider(create: (_) => FeesProvider()),
        ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
        ChangeNotifierProvider(create: (_) => BatchProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => StudentLoginProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => TeacherLoginProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: AppRouting.routes,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
