import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:studify/main.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool Isloading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle() async {
      const webClientId =
          '336001241079-v8fa46fcd1uqj6i4s0163ndqsrfaim6o.apps.googleusercontent.com';

      try {
        setState(() => Isloading = true);

        // 🔥 IMPORTANT: Clear previous admin data
        final adminProvider = Provider.of<AdminProfileProvider>(
          context,
          listen: false,
        );
        adminProvider.clearAdminData();

        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(serverClientId: webClientId);

        if (googleSignIn.supportsAuthenticate()) {
          final googleUser = await googleSignIn.authenticate();
          final googleAuth = await googleUser.authentication;

          final idToken = googleAuth.idToken;
          if (idToken == null) throw 'No ID Token found.';

          final response = await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );

          final user = response.user;

          if (user == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Login failed ❌',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            debugPrint("Supabase login failed: No user found");
            return;
          }

          final userEmail = user.email;
          debugPrint("🔄 User logged in successfully: $userEmail");

          // Check if admin is already registered
          final existingAdmin = await supabase
              .from('admin')
              .select()
              .eq('email', userEmail!)
              .maybeSingle();

          if (!mounted) return;

          if (existingAdmin == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome new admin! Please complete signup.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pushNamed(context, '/adminsingup');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back ${existingAdmin['name']}!'),
                backgroundColor: Colors.green,
              ),
            );

            // 🔥 IMPORTANT: Force fetch fresh admin data
            await adminProvider.Fatchdata();

            // 🔥 Wait for admin data to load before navigation
            if (adminProvider.adminId != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admindashboard',
                (route) => false,
                arguments: {
                  'academy_name': existingAdmin['academy_name'],
                  'email': existingAdmin['email'],
                  'id': existingAdmin['id'],
                },
              );
            } else {
              throw 'Failed to load admin data';
            }
          }
        }
      } catch (e) {
        debugPrint("Google Sign-In error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => Isloading = false);
      }
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Image.asset('assets/images/appbg.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset('assets/images/stulogo.png', height: 200),
                ),

                const SizedBox(height: 30),

                Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                InkWell(
                  onTap: signInWithGoogle,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 230,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Isloading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/googlelogo.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
