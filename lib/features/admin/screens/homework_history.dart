import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/utils/appbar.dart';

class AdminHomeworkListScreen extends StatefulWidget {
  final String batchId;
  final String batchName;
  final int adminId;

  const AdminHomeworkListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.adminId,
  });

  @override
  State<AdminHomeworkListScreen> createState() =>
      _AdminHomeworkListScreenState();
}

class _AdminHomeworkListScreenState extends State<AdminHomeworkListScreen> {
  File? selectedFile;
  bool isLoading = true;
  bool isError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomework();
    });
  }

  Future<void> _loadHomework() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isError = false;
        errorMessage = null;
      });
    }

    try {
      final provider = context.read<HomeworkProvider>();
      await provider.fetchHomeworkByBatch(widget.batchId, widget.adminId);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openMaterial(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/$fileName');

      if (await localFile.exists()) {
        await OpenFilex.open(localFile.path);
        return;
      }

      final provider = context.read<HomeworkProvider>();
      final signedUrl = await provider.getSignedUrl(filePath);
      if (signedUrl == null) throw Exception('Could not generate signed URL');

      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      await localFile.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(localFile.path);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error Opening File'),
          content: Text('Unable to open file.\n\nError: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showEditDialog(
    BuildContext context,
    HomeworkProvider provider,
    Map hw,
  ) {
    final titleCtrl = TextEditingController(text: hw['title'] ?? '');
    final descCtrl = TextEditingController(text: hw['description'] ?? '');
    selectedFile = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.edit, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Edit Homework'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: Text(
                      selectedFile == null
                          ? 'Change File (Optional)'
                          : 'Change File',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'pdf',
                              'docx',
                              'png',
                              'jpg',
                              'mp4',
                            ],
                          );
                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          selectedFile = File(result.files.single.path!);
                        });
                      }
                    },
                  ),
                  if (selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '📄 ${selectedFile!.path.split('/').last}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  String? uploadedFilePath = hw['material_link'];

                  if (selectedFile != null) {
                    final teacherId = hw['teacher_id']?.toString() ?? '';
                    debugPrint('🟡 Uploading file for teacher: $teacherId');

                    uploadedFilePath = await provider.uploadMaterial(
                      selectedFile!,
                      teacherId,
                    );
                  }

                  final success = await provider.updateHomework(
                    id: hw['id'].toString(), // Ensure ID is string
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    materialLink: uploadedFilePath,
                  );

                  if (success && mounted) {
                    Navigator.pop(context);
                    await _loadHomework();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Homework updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Failed to update homework'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeworkProvider>();

    return Scaffold(
      appBar: ReuseAppbar(name: '${widget.batchName} Homework'),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading homework',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage ?? 'Unknown error',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHomework,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : provider.homeworkList.isEmpty
          ? const Center(
              child: Text(
                'No homework available.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHomework,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.homeworkList.length,
                itemBuilder: (context, i) {
                  final hw = provider.homeworkList[i];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.assignment, color: Colors.white),
                      ),
                      title: Text(
                        hw['title'] ?? 'Untitled Homework',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            hw['description'] ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '👨‍🏫 Teacher: ${hw['teacher_name'] ?? 'Unknown'}',
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'view' && hw['material_link'] != null) {
                            _openMaterial(hw['material_link']);
                          } else if (value == 'edit') {
                            _showEditDialog(context, provider, hw);
                          }
                        },
                        itemBuilder: (context) => [
                          if (hw['material_link'] != null)
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text('View File'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
