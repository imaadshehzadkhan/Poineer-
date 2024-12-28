import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String localPath = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    print('PDFViewerPage: Starting download for: ${widget.pdfUrl}');

    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      // Log the status code
      print('PDFViewerPage: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Save PDF file to temporary directory
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');

        // Log the directory path
        print('PDFViewerPage: Writing PDF to: ${file.path}');

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
        print('PDFViewerPage: PDF download complete. localPath=$localPath');
      } else {
        // Log the error
        print('PDFViewerPage: Failed to load PDF. Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load PDF (status: ${response.statusCode}).');
      }
    } catch (e, stack) {
      print('PDFViewerPage: Exception during PDF download -> $e');
      print(stack);
      setState(() {
        isLoading = false;
      });
      rethrow; // or handle the error in a user-friendly way
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PDFViewerPage: build() called. isLoading=$isLoading, localPath=$localPath');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View PDF',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath.isNotEmpty
          ? PDFView(
        filePath: localPath,
        fitEachPage: true,
        autoSpacing: true,
        enableSwipe: true,
        swipeHorizontal: false,
      )
          : const Center(
        child: Text(
          'Failed to load PDF.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
