import 'package:flutter/material.dart';
import 'package:studify/utils/appbar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Coming Soon"),
        content: const Text("This feature is under development."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: ReuseAppbar(name: "Settings"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // ---------- PROFILE CARD ----------
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: Colors.blue.shade700,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   width: double.infinity,
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 33,
            //         backgroundColor: Colors.white,
            //         child: Icon(
            //           Icons.person,
            //           size: 40,
            //           color: Colors.blue.shade700,
            //         ),
            //       ),
            //       const SizedBox(width: 16),
            //       const Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             "Student Name",
            //             style: TextStyle(
            //               fontSize: 20,
            //               color: Colors.white,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //           Text(
            //             "Class: XII – Science",
            //             style: TextStyle(fontSize: 15, color: Colors.white70),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 22),

            // ---------- ACCOUNT SETTINGS ----------
            _sectionTitle("Account Settings"),
            _bigSettingTile(
              title: "Profile",
              icon: Icons.person_outline,
              context: context,
              onTap: () => _showComingSoon(context),
            ),
            _bigSettingTile(
              title: "Change Password",
              icon: Icons.lock_outline,
              context: context,
              onTap: () => _showComingSoon(context),
            ),
            _bigSettingTile(
              title: "Manage Notifications",
              icon: Icons.notifications_none,
              context: context,
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 22),

            // ---------- APP SETTINGS ----------
            _sectionTitle("App Settings"),
            _bigSettingTile(
              title: "Appearance",
              icon: Icons.color_lens_outlined,
              context: context,
              onTap: () => _showComingSoon(context),
            ),
            _bigSettingTile(
              title: "Language",
              icon: Icons.language,
              context: context,
              onTap: () => _showComingSoon(context),
            ),
            _bigSettingTile(
              title: "Backup & Restore",
              icon: Icons.cloud_sync_outlined,
              context: context,
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 22),

            _sectionTitle("Help & Support"),
            _bigSettingTile(
              title: "Help Center",
              icon: Icons.help_outline,
              context: context,
              onTap: () => _showComingSoon(context),
            ),
            _bigSettingTile(
              title: "About App",
              icon: Icons.info_outline,
              context: context,
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 22),

            _bigSettingTile(
              title: "Logout",
              icon: Icons.logout,
              iconColor: Colors.red,
              textColor: Colors.red,
              context: context,
              onTap: () => Navigator.pushNamed(context, '/rolescreen'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bigSettingTile({
    required String title,
    required IconData icon,
    required BuildContext context,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
