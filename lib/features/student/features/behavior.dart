import 'package:flutter/material.dart';
import 'package:studify/main.dart';
import 'package:studify/utils/appbar.dart';

class StudentBehaviorScreen extends StatefulWidget {
  final String studentId;
  final int adminId;

  const StudentBehaviorScreen({
    super.key,
    required this.studentId,
    required this.adminId,
  });

  @override
  State<StudentBehaviorScreen> createState() => _StudentBehaviorScreenState();
}

class _StudentBehaviorScreenState extends State<StudentBehaviorScreen> {
  Map<String, dynamic>? behaviorData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBehavior();
  }

  Future<void> fetchBehavior() async {
    try {
      final data = await supabase
          .from("behavior_records")
          .select()
          .eq("student_id", widget.studentId)
          .eq("admin_id", widget.adminId)
          .order("created_at", ascending: false)
          .limit(1);

      if (data.isNotEmpty) {
        setState(() {
          behaviorData = data.first;
        });
      }
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildRatingRow(String title, int? value) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            value ?? 0,
            (index) => const Icon(Icons.star, color: Colors.orange),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Behavior Report'),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : behaviorData == null
          ? const Center(
              child: Text(
                "No behavior rating given yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRatingRow(
                    "Class Behavior",
                    behaviorData!["class_behavior"],
                  ),
                  buildRatingRow("Games", behaviorData!["games"]),
                  buildRatingRow("Homework", behaviorData!["homework"]),
                  buildRatingRow("Discipline", behaviorData!["discipline"]),
                  buildRatingRow(
                    "Communication",
                    behaviorData!["communication"],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Remarks",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    behaviorData!["remarks"] ?? "No remarks",
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Last Updated: ${behaviorData!["created_at"].toString().split('T').first}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
