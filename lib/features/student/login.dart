import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/student/login.dart';
import 'package:studify/features/admin/auth/signup.dart';
import 'package:studify/features/student/dashboard.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentLoginProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/studenttlogo.png',
                  height: 140,
                  width: 140,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Welcome Back 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to your student account',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 35),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ReuseTextfield(
                      controller: emailcontroller,
                      text: 'Enter email',
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter your email'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    ReuseTextfield(
                      controller: passwordcontroller,
                      text: 'Enter Password',
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter your password'
                          : null,
                    ),
                    const SizedBox(height: 40),

                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF667EEA), // soft indigo
                            Color(0xFF764BA2), // royal purple
                            Color(0xFF6B8DD6), // sky violet
                            Color(0xFF8E37D7), // deep purple accent
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);
                                  final student = await studentProvider
                                      .loginStudent(
                                        email: emailcontroller.text,
                                        password: passwordcontroller.text,
                                      );
                                  setState(() => isLoading = false);

                                  if (student != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Login Successful ✅'),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentDashboard(
                                          studentData: student,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Invalid email or password ❌',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
