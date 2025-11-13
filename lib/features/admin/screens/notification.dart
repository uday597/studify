import 'package:flutter/material.dart';
import 'package:studify/utils/appbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Assignment Posted',
        'message': 'Maths Assignment #5 has been uploaded by Mr. Sharma.',
        'time': '10:45 AM',
        'icon': Icons.assignment_outlined,
        'color': Colors.blueAccent,
      },
      {
        'title': 'Attendance Updated',
        'message': 'Your attendance for this week is 92%. Keep it up!',
        'time': 'Yesterday',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      {
        'title': 'Fee Reminder',
        'message': 'Your next fee installment is due on 20th Nov 2025.',
        'time': '2 days ago',
        'icon': Icons.currency_rupee,
        'color': Colors.orange,
      },
      {
        'title': 'Event Invitation',
        'message': 'Join the Annual Sports Meet on 25th Nov 2025!',
        'time': '3 days ago',
        'icon': Icons.celebration_outlined,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: ReuseAppbar(name: 'Notifications'),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet 🎉',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔔 Notification list
                  ListView.separated(
                    itemCount: notifications.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: (n['color'] as Color).withOpacity(
                              0.15,
                            ),
                            child: Icon(
                              n['icon'] as IconData,
                              color: n['color'] as Color,
                            ),
                          ),
                          title: Text(
                            n['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            n['message'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            n['time'] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // 💬 Connect with Us section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'If you have any issues or queries, feel free to connect with us!',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/contact');
                              },
                              icon: const Icon(Icons.support_agent),
                              label: const Text('Contact Us'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.feedback_outlined),
                              label: const Text('Give Feedback'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.blueAccent,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: const Color(0xfff6f8fb),
    );
  }
}
