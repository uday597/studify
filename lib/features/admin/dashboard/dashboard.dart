import 'package:flutter/material.dart';
import 'package:studify/features/admin/screens/exam_batch.dart';
import 'package:studify/features/admin/screens/quiz.dart';
import 'package:studify/features/admin/screens/todo.dart';
import 'package:studify/main.dart';
import 'package:studify/features/admin/screens/staff_attendance.dart';
import 'package:studify/features/admin/screens/student_attendance.dart';
import 'package:studify/utils/reuselist.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? academyName;
  String? email;
  String? adminId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.settings.arguments != null) {
      final args = route.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          academyName = args['academy_name'];
          email = args['email'];
          adminId = args['id']?.toString();
        });
      }
    } else {
      debugPrint('⚠️ No arguments were passed to AdminDashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu, size: 30),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'Main Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/stulogo.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    academyName ?? 'Academy Name',
                    style: TextStyle(
                      letterSpacing: 2,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email ?? 'Email not available',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.home, color: Colors.indigo),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/adminprofile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.deepOrange),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () async {
                await supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/rolescreen');
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.lightBlueAccent, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/adminprofile');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          color: Color.fromARGB(100, 0, 0, 0),
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/stulogo.png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                academyName ?? 'Academy name not available',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: isSmallScreen ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email ?? 'Email not available',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/adminbatch');
                },
                image: 'assets/images/batchicon.png',
                text: 'Batch',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/adminstudents');
                },
                image: 'assets/images/studenticon.png',
                text: 'Student',
              ),
              reuseList(
                onTap: () {
                  Navigator.pop(context);
                  final parsedAdminId = int.tryParse(adminId ?? '');
                  if (parsedAdminId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Admin numeric ID not available. Please sync admin profile.',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentAttendanceScreen(adminId: parsedAdminId),
                    ),
                  );
                },
                image: 'assets/images/attendanceicon.png',
                text: 'Student Attendance',
              ),
              reuseList(
                onTap: () {
                  Navigator.pop(context);
                  final parsedAdminId = int.tryParse(adminId ?? '');
                  if (parsedAdminId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Admin numeric ID not available. Please sync admin profile.',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherAttendanceScreen(adminId: parsedAdminId),
                    ),
                  );
                },
                image: 'assets/images/teacher_attendance.png',
                text: 'Teacher Attendance',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/adminstudents');
                },
                image: 'assets/images/studenticon.png',
                text: 'Student',
              ),
              reuseList(
                onTap: () {},
                image: 'assets/images/questioning.png',
                text: 'Enquiry Manager',
              ),
              reuseList(
                onTap: () {
                  final parsedAdminId = int.tryParse(adminId ?? '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToDoScreen(adminId: parsedAdminId!),
                    ),
                  );
                },
                image: 'assets/images/toDo.png',
                text: 'ToDo',
              ),

              reuseList(
                onTap: () async {
                  try {
                    print('🔄 Fetching admin data directly...');

                    final user = supabase.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    print('📧 Current user email: ${user.email}');

                    final response = await supabase
                        .from('admin')
                        .select('id, academy_name, email')
                        .eq('email', user.email!);

                    print('🔍 Admin query response: $response');

                    if (response.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin profile not found in database'),
                        ),
                      );
                      return;
                    }

                    final adminData = response.first;
                    final adminId = adminData['id'];

                    if (adminId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin ID is null in database'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamBatchSelectionScreen(
                          userType: 'admin',
                          userId: adminId.toString(),
                          adminId: adminId is int
                              ? adminId
                              : int.parse(adminId.toString()),
                        ),
                      ),
                    );
                  } catch (e) {
                    print('❌ Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching admin data: $e')),
                    );
                  }
                },
                image: 'assets/images/exam.png',
                text: 'Manage Exams',
              ),
              reuseList(
                onTap: () {
                  final parsedAdminId = int.tryParse(adminId ?? '');
                  if (parsedAdminId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Admin ID not available. Please sync admin profile.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  // Navigate after a small delay to ensure provider is ready
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BatchSelectionScreen(),
                        settings: RouteSettings(
                          arguments: {
                            'id': parsedAdminId,
                            'academy_name': academyName,
                            'email': email,
                          },
                        ),
                      ),
                    );
                  });
                },
                image: 'assets/images/ideas.png',
                text: 'Quiz Management',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/tutionfees');
                },
                image: 'assets/images/feesicon.png',
                text: 'Tuition Fees',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/contactsupport');
                },
                image: 'assets/images/contactuslogo.png',
                text: 'Contact Support',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
