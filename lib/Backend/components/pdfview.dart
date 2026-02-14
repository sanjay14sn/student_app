import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  static const platform = MethodChannel('secure_channel');

  @override
  void initState() {
    super.initState();
    _enableSecureFlag();
    _listenForScreenshotAttempt();
  }

  @override
  void dispose() {
    _disableSecureFlag();
    super.dispose();
  }

  Future<void> _enableSecureFlag() async {
    try {
      await platform.invokeMethod('blockScreenshots');
    } catch (e) {}
  }

  Future<void> _disableSecureFlag() async {
    try {
      await platform.invokeMethod('allowScreenshots');
    } catch (e) {}
  }

  void _listenForScreenshotAttempt() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "screenshotAttempt") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Screenshot blocked for privacy"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3192),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// 👇 NETWORK VIEWER (IMPORTANT)
      body: SfPdfViewer.network(widget.pdfPath),
    );
  }
}
