import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/utils/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class HomeworkListScreen extends StatefulWidget {
  final String batchId;
  final String batchName;
  final int adminId;
  final String teacherId;

  const HomeworkListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
    required this.adminId,
    required this.teacherId,
  });

  @override
  State<HomeworkListScreen> createState() => _HomeworkListScreenState();
}

class _HomeworkListScreenState extends State<HomeworkListScreen> {
  File? selectedFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomework();
    });
  }

  Future<void> _loadHomework() async {
    final provider = context.read<HomeworkProvider>();
    await provider.fetchHomeworkByBatch(widget.batchId, widget.adminId);
    setState(() => isLoading = false);
  }

  String _getFileType(String filePath) {
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.endsWith('.pdf')) return 'PDF';
    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png'))
      return 'Image';
    if (lowerPath.endsWith('.docx')) return 'Document';
    if (lowerPath.endsWith('.mp4')) return 'Video';
    return 'File';
  }

  Future<void> _openMaterial(String filePath) async {
    try {
      debugPrint('🟡 Opening file: $filePath');

      final provider = context.read<HomeworkProvider>();
      final signedUrl = await provider.getSignedUrl(filePath);

      if (signedUrl == null) {
        throw Exception('Could not generate signed URL');
      }

      debugPrint('🔗 Signed URL: $signedUrl');

      // Download file first then open
      final fileName = filePath.split('/').last;
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/$fileName');

      // Check if file already exists
      if (await localFile.exists()) {
        debugPrint('📂 File already cached: ${localFile.path}');
        await OpenFilex.open(localFile.path);
        return;
      }

      // Download file
      debugPrint('⬇️ Downloading file...');
      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      // Save file locally
      await localFile.writeAsBytes(response.bodyBytes);
      debugPrint('✅ File saved: ${localFile.path}');

      // Open file
      await OpenFilex.open(localFile.path);
      debugPrint('✅ File opened successfully');
    } catch (e) {
      debugPrint('❌ Error opening file: $e');
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

  void _showAddDialog(BuildContext context, HomeworkProvider provider) {
    selectedFile = null;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

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
                Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Add Homework'),
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
                      selectedFile == null ? 'Attach Material' : 'Change File',
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
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  String? uploadedFilePath;
                  if (selectedFile != null) {
                    uploadedFilePath = await provider.uploadMaterial(
                      selectedFile!,
                      widget.teacherId,
                    );
                  }

                  await provider.addHomework(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    materialLink: uploadedFilePath,
                    batchId: widget.batchId,
                    teacherId: widget.teacherId,
                    adminId: widget.adminId,
                  );
                  selectedFile = null;
                  Navigator.pop(context);
                  await _loadHomework();
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
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.homeworkList.isEmpty
          ? const Center(
              child: Text(
                'No homework yet.\nTap + to add one!',
                textAlign: TextAlign.center,
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER ROW
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.assignment,
                                    color: Colors.blueAccent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    hw["title"] ?? "Untitled Homework",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: .3,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// DESCRIPTION
                            Text(
                              hw["description"] ?? "",
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (hw["material_link"] != null)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    label: Text(
                                      "View ${_getFileType(hw["material_link"])}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onPressed: () =>
                                        _openMaterial(hw["material_link"]),
                                  ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Delete Homework"),
                                        content: const Text(
                                          "Are you sure you want to delete this homework?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await provider.deleteHomework(
                                        hw["id"].toString(),
                                        hw["material_link"],
                                        widget.batchId,
                                        widget.adminId,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Homework",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showAddDialog(context, provider),
      ),
    );
  }
}
