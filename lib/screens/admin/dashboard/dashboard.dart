import 'package:flutter/material.dart';
import 'package:studify/main.dart';
import 'package:studify/screens/admin/features/staff_attendance.dart';
import 'package:studify/screens/admin/features/student_attendance.dart';
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
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
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () async {
                await supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/adminlogin');
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
                color: Colors.indigoAccent,
                image: 'assets/images/batchicon.png',
                text: 'Batch',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/adminstudents');
                },
                color: Colors.teal,
                image: 'assets/images/studenticon.png',
                text: 'Student',
              ),
              reuseList(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.indigo,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Mark Attendance",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Please choose which attendance you want to mark.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // 🧑‍🎓 Student Attendance Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final parsedAdminId = int.tryParse(
                                        adminId ?? '',
                                      );
                                      if (parsedAdminId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                              StudentAttendanceScreen(
                                                adminId: parsedAdminId,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Student",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  // 👩‍🏫 Teacher Attendance Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final parsedAdminId = int.tryParse(
                                        adminId ?? '',
                                      );
                                      if (parsedAdminId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                              TeacherAttendanceScreen(
                                                adminId: parsedAdminId,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Teacher",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                color: Colors.deepOrangeAccent,
                image: 'assets/images/attendanceicon.png',
                text: 'Attendance',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/addteacher');
                },
                color: Colors.purpleAccent,
                image: 'assets/images/stafficon.png',
                text: 'Staff Manager',
              ),
              reuseList(
                onTap: () {
                  Navigator.pushNamed(context, '/tutionfees');
                },
                color: Colors.blueGrey,
                image: 'assets/images/feesicon.png',
                text: 'Tuition Fees',
              ),
              reuseList(
                onTap: () {},
                color: Colors.black54,
                image: 'assets/images/settingsicon.png',
                text: 'Settings',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
