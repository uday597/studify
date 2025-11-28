import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/behavior.dart';
import 'package:studify/utils/appbar.dart';

class BehaviorRatingScreen extends StatefulWidget {
  final String studentId;
  final String batchId;
  final int adminId;

  const BehaviorRatingScreen({
    super.key,
    required this.studentId,
    required this.batchId,
    required this.adminId,
  });

  @override
  State<BehaviorRatingScreen> createState() => _BehaviorRatingScreenState();
}

class _BehaviorRatingScreenState extends State<BehaviorRatingScreen> {
  TextEditingController remarkcontroller = TextEditingController();
  int classRate = 1;
  int gamesRate = 1;
  int homeworkRate = 1;
  int disciplineRate = 1;
  int communicationRate = 1;

  Widget buildStars(String title, int value, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Row(
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < value ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => onChanged(i + 1),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Give Rating'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildStars(
                "Class Behavior",
                classRate,
                (v) => setState(() => classRate = v),
              ),
              buildStars(
                "Games",
                gamesRate,
                (v) => setState(() => gamesRate = v),
              ),
              buildStars(
                "Homework",
                homeworkRate,
                (v) => setState(() => homeworkRate = v),
              ),
              buildStars(
                "Discipline",
                disciplineRate,
                (v) => setState(() => disciplineRate = v),
              ),
              buildStars(
                "Communication",
                communicationRate,
                (v) => setState(() => communicationRate = v),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: remarkcontroller,
                decoration: InputDecoration(
                  label: Text('Give Remarks'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<BehaviorProvider>();
                  try {
                    await provider.addBehavior(
                      studentId: widget.studentId,
                      batchId: widget.batchId,
                      adminId: widget.adminId,
                      classBehavior: classRate,
                      games: gamesRate,
                      homework: homeworkRate,
                      discipline: disciplineRate,
                      communication: communicationRate,
                      remarks: remarkcontroller.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rating submitted ✅")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to submit: $e")),
                    );
                  }
                },
                child: const Text("Submit Rating"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
