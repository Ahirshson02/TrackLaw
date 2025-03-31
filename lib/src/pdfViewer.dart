import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final String filePath;
  const PDFViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool isLoading = true;
  int totalPages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Stack(
                  children: [
                    PDFView(
                      filePath: widget.filePath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      //autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      fitPolicy: FitPolicy.WIDTH,
                      fitEachPage: true,
                      onRender: (pages) {
                        setState(() {
                          totalPages = pages!;
                        });
                      },
                      onPageChanged: (page, total) {
                        setState(() {
                          currentPage = page!;
                        });
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${currentPage + 1} of $totalPages',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
    );
  }
}
