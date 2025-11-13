import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/utils/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class StudentHomework extends StatefulWidget {
  final String batchId;
  final int adminId;

  const StudentHomework({
    super.key,
    required this.batchId,
    required this.adminId,
  });

  @override
  State<StudentHomework> createState() => _StudentHomeworkState();
}

class _StudentHomeworkState extends State<StudentHomework> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  Future<void> _loadHomework() async {
    final provider = context.read<HomeworkProvider>();
    await provider.fetchHomeworkByBatch(widget.batchId, widget.adminId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeworkProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Homework'),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : provider.homeworkList.isEmpty
          ? const Center(child: Text('No homework assigned yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.homeworkList.length,
              itemBuilder: (context, index) {
                final hw = provider.homeworkList[index];
                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assignment, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hw['title'] ?? 'Untitled Homework',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hw['description'] ?? 'No description provided',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (hw['material_link'] != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Preview Material',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _openMaterialPreview(
                                context,
                                hw['material_link'],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openMaterialPreview(
    BuildContext context,
    String filePath,
  ) async {
    try {
      final fileName = filePath.split('/').last;
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/$fileName');

      // ✅ 1️⃣ If file already exists locally, open instantly
      if (await localFile.exists()) {
        debugPrint('⚡ Opening cached file: ${localFile.path}');
        await OpenFilex.open(localFile.path);
        return;
      }

      // ✅ 2️⃣ Otherwise, show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 3,
          ),
        ),
      );

      // ✅ 3️⃣ Generate signed URL and download file
      final provider = context.read<HomeworkProvider>();
      final signedUrl = await provider.getSignedUrl(filePath);
      if (signedUrl == null) throw Exception('Could not generate signed URL');

      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      // ✅ 4️⃣ Save file locally for next time
      await localFile.writeAsBytes(response.bodyBytes);
      debugPrint('📁 File cached at: ${localFile.path}');

      // ✅ 5️⃣ Close loading dialog
      Navigator.pop(context);

      // ✅ 6️⃣ Open file instantly
      final result = await OpenFilex.open(localFile.path);
      debugPrint('📂 Open result: ${result.message}');
    } catch (e) {
      Navigator.pop(context); // Close dialog if open
      debugPrint('❌ Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
