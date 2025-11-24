// teacher_batch_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:studify/features/teacher/screens/quiz_create.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherBatchSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeacherBatchSelectionScreen({super.key, required this.teacherData});

  @override
  State<TeacherBatchSelectionScreen> createState() =>
      _TeacherBatchSelectionScreenState();
}

class _TeacherBatchSelectionScreenState
    extends State<TeacherBatchSelectionScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<dynamic> _batches = [];
  bool _loading = true;
  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final batchesData = await _supabase
          .from('batches')
          .select('*')
          .eq('admin_id', widget.teacherData['admin_id'])
          .order('name');

      setState(() {
        _batches = batchesData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Batch'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
          ? _buildNoBatches()
          : _buildBatchList(),
    );
  }

  Widget _buildNoBatches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.class_, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No batches found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select batch to manage quizzes:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Batch Selection
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBatchId,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Select Batch'),
                ),
                items: _batches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch['id'],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${batch['name']} - ${batch['location']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBatchId = newValue;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Continue Button
          if (_selectedBatchId != null)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final selectedBatch = _batches.firstWhere(
                    (batch) => batch['id'] == _selectedBatchId,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherQuizManagementScreen(
                        batchId: _selectedBatchId!,
                        batchName: selectedBatch['name'],
                        adminId: widget.teacherData['admin_id'],
                        teacherData: widget.teacherData,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text('Manage Quizzes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
