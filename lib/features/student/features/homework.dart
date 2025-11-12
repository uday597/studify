import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/homework.dart';
import 'package:studify/utils/appbar.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
      // 🟢 Get signed URL for private file
      final provider = context.read<HomeworkProvider>();
      final signedUrl = await provider.getSignedUrl(filePath);

      if (signedUrl == null) {
        throw Exception('Could not generate access URL');
      }

      debugPrint('🔗 Signed URL: $signedUrl');

      final lowerUrl = signedUrl.toLowerCase();

      if (lowerUrl.contains('.pdf')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PDFViewerScreen(pdfUrl: signedUrl)),
        );
      } else if (lowerUrl.contains('.jpg') ||
          lowerUrl.contains('.jpeg') ||
          lowerUrl.contains('.png')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(imageUrl: signedUrl),
          ),
        );
      } else {
        if (await canLaunchUrl(Uri.parse(signedUrl))) {
          await launchUrl(
            Uri.parse(signedUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Opening File'),
          content: Text('The file cannot be opened. Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      debugPrint('❌ Error opening material: $e');
    }
  }
}

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
      appBar: AppBar(title: const Text("Preview PDF")),
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

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Image')),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.white),
      ),
    );
  }
}
