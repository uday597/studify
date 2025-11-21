import 'package:flutter/material.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 92, 203, 255),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
            vertical: size.height * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              RoleCard(
                onTap: () => Navigator.pushNamed(context, '/adminlogin'),
                image: 'assets/images/adminlogo.png',
                text: 'Admin Login',
                color1: Colors.white,
                color2: Colors.lightBlueAccent,
              ),
              SizedBox(height: size.height * 0.03),
              RoleCard(
                onTap: () {
                  Navigator.pushNamed(context, '/teacherlogin');
                },
                image: 'assets/images/teacherlogo.jpg',
                text: 'Teacher Login',
                color1: Colors.white,
                color2: Colors.lightBlueAccent,
              ),
              SizedBox(height: size.height * 0.03),
              RoleCard(
                onTap: () => Navigator.pushNamed(context, '/studentlogin'),
                image: 'assets/images/studenttlogo.png',
                text: 'Student Login',
                color1: Colors.white,
                color2: Colors.lightBlueAccent,
              ),
              SizedBox(height: size.height * 0.05),
              Text(
                'By signing in, you agree to our',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.048,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onTap;
  final Color color1;
  final Color color2;

  const RoleCard({
    super.key,
    required this.image,
    required this.text,
    required this.onTap,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white24,
      child: Container(
        width: double.infinity,
        height: size.height * 0.25,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1.withOpacity(0.95), color2.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
