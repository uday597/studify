import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/utils/appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
    _loadHomework();
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
    return 'File';
  }

  Future<void> _openMaterial(String filePath) async {
    try {
      final provider = context.read<HomeworkProvider>();
      final signedUrl = await provider.getSignedUrl(filePath);

      if (signedUrl == null) throw Exception('Could not generate access URL');

      debugPrint('🔗 Signed URL: $signedUrl');

      final lowerUrl = signedUrl.toLowerCase();

      if (lowerUrl.contains('.pdf')) {
        // 🟢 Use built-in PDF viewer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PDFViewerScreen(pdfUrl: signedUrl)),
        );
      } else if (lowerUrl.contains('.jpg') ||
          lowerUrl.contains('.jpeg') ||
          lowerUrl.contains('.png')) {
        // 🟢 Use built-in image viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(imageUrl: signedUrl),
          ),
        );
      } else {
        // For other file types, use external app
        if (await canLaunchUrl(Uri.parse(signedUrl))) {
          await launchUrl(
            Uri.parse(signedUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch URL');
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Opening File'),
          content: Text('The file cannot be opened.\n\nError: $e'),
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
                            allowedExtensions: ['pdf', 'docx', 'png', 'jpg'],
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
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hw['title'] ?? 'Untitled Homework',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hw['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (hw['material_link'] != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.blueAccent,
                                ),
                                label: Text(
                                  'View ${_getFileType(hw['material_link'])}',
                                ),
                                onPressed: () =>
                                    _openMaterial(hw['material_link']),
                              ),
                            ),
                        ],
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

// 🟢 PDF Viewer Screen for Teacher
class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PDFViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool loading = true;
  String? localPath;

  @override
  void initState() {
    super.initState();
    _downloadAndShowPDF();
  }

  Future<void> _downloadAndShowPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPath = file.path;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview PDF"),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
          ? const Center(child: Text('Failed to load PDF'))
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            ),
    );
  }
}

// 🟢 Image Viewer Screen for Teacher
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Preview Image'),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
      ),
    );
  }
}
