// batch_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/features/admin/screens/create_quiz.dart';
import 'package:studify/provider/admin/features/batch.dart';

class BatchSelectionScreen extends StatefulWidget {
  const BatchSelectionScreen({super.key});

  @override
  State<BatchSelectionScreen> createState() => _BatchSelectionScreenState();
}

class _BatchSelectionScreenState extends State<BatchSelectionScreen> {
  String? _selectedBatchId;
  int? _adminId;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.delayed(Duration.zero);

      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final args = route.settings.arguments as Map<String, dynamic>;
        _adminId = int.tryParse(args['id']?.toString() ?? '');

        if (_adminId != null) {
          final batchProvider = Provider.of<BatchProvider>(
            context,
            listen: false,
          );
          await batchProvider.fetchData(adminId: _adminId!);
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Admin ID not found';
          });
          return;
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No arguments provided';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading batches: $e';
      });
      debugPrint('Error initializing batch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = Provider.of<BatchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Batch for Quiz'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _initializeData,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading batches...'),
                ],
              ),
            )
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Error loading batches',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildBatchList(batchProvider),
    );
  }

  Widget _buildBatchList(BatchProvider batchProvider) {
    if (batchProvider.batches.isEmpty) {
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
            const SizedBox(height: 8),
            Text(
              'Create batches first to add quizzes',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminbatch');
              },
              child: const Text('Create Batch'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a batch to manage quizzes:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

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
                items: batchProvider.batches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch['id'],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            batch['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Location: ${batch['location']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

          if (_selectedBatchId != null)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final selectedBatch = batchProvider.batches.firstWhere(
                    (batch) => batch['id'] == _selectedBatchId,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizManagementScreen(
                        batchId: _selectedBatchId!,
                        batchName: selectedBatch['name'],
                        adminId: _adminId!,
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

          // Batch List
          const SizedBox(height: 24),
          const Text(
            'Available Batches:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, index) {
                final batch = batchProvider.batches[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.class_,
                      color: Colors.lightBlueAccent,
                    ),
                    title: Text(
                      batch['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Location: ${batch['location']}'),
                    trailing: _selectedBatchId == batch['id']
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedBatchId = batch['id'];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
