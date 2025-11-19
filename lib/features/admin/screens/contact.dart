import 'package:flutter/material.dart';
import 'package:studify/utils/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  // Launch Email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'udaykabir4@gmail.com',
      query: Uri.encodeFull(
        'subject=Support Request&body=Hello, I need help with...',
      ),
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open email app')));
    }
  }

  // Launch WhatsApp
  Future<void> _launchWhatsApp() async {
    const phone = '+917404590460';
    const message = 'Hello! I would like to contact you.';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _launchlinkdin() async {
    final Uri site = Uri.parse('https://www.linkedin.com/in/uday-256b15342/');
    await launchUrl(site, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchFB() async {
    final Uri site = Uri.parse('https://www.facebook.com/uday.kabir.2025');
    await launchUrl(site, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchInsta() async {
    final Uri site = Uri.parse(
      'https://www.instagram.com/uday_kabir/reels/?__d=1',
    );
    await launchUrl(site, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchCall() async {
    final Uri call = Uri(scheme: 'tel', path: '+917404590460');
    await launchUrl(call, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Contact Us'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 90, color: Colors.blueAccent),
            const SizedBox(height: 20),

            const Text(
              'We’d love to hear from you!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),
            const Text(
              'Whether you have a question, feedback, or just want to say hi — we’re here for you!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Email Button
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Email Us'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // WhatsApp Button
            ElevatedButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat),
              label: const Text('Chat on WhatsApp'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Call Button
            ElevatedButton.icon(
              onPressed: _launchCall,
              icon: const Icon(Icons.phone),
              label: const Text('Call Us'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 Our Office',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('KabirTech\nHaryana, Ambala-Cantt, India'),
                  SizedBox(height: 16),
                  Text(
                    '🕒 Working Hours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Monday - Saturday\n10:00 AM - 7:00 PM'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Follow Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _launchFB,
                  child: Image.asset(
                    'assets/images/fblogo.webp',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 20),

                GestureDetector(
                  onTap: () {
                    _launchInsta();
                  },
                  child: Image.asset(
                    'assets/images/instalogo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 20),

                GestureDetector(
                  onTap: () {
                    _launchlinkdin();
                  },
                  child: Image.asset(
                    'assets/images/linkdinlogo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              '© 2025 Studify Academy\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
