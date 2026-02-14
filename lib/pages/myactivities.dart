import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class UploadFilesPage extends StatefulWidget {
  const UploadFilesPage({super.key});

  @override
  State<UploadFilesPage> createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  final storage = const FlutterSecureStorage();
  final Dio dio = Dio();

  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> attachments = [];
  double uploadProgress = 0;
  bool submitting = false;

  int _selectedIndex = 1;

  final String postHomeworkUrl =
      "https://optimista.in/backup/tution/Posthomework.php";

  // PICK FILES (DO NOT UPLOAD YET)
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    setState(() {
      for (final f in result.files) {
        attachments.add({
          "file": File(f.path!),
          "name": f.name,
          "fileType": detectType(f.name),
        });
      }
    });

    print("📂 FILES SELECTED:");
    for (var a in attachments) {
      print("👉 ${a['name']} | TYPE: ${a['fileType']}");
    }

    Fluttertoast.showToast(msg: "Files added to upload list");
  }

  // DETECT FILE TYPE
  String detectType(String name) {
    final n = name.toLowerCase();
    if (n.endsWith(".jpg") || n.endsWith(".png")) return "image";
    if (n.endsWith(".pdf")) return "pdf";
    if (n.endsWith(".mp4")) return "video";
    return "file";
  }
Future<void> submitHomework() async {
  final description = descriptionController.text.trim();

  if (description.isEmpty || attachments.isEmpty) {
    Fluttertoast.showToast(
      msg: "Enter description & select at least one file",
    );
    return;
  }

  final token = await storage.read(key: "token");

  setState(() {
    submitting = true;
    uploadProgress = 0;
  });

  try {
    List<MultipartFile> files = [];

    for (var att in attachments) {
      files.add(
        await MultipartFile.fromFile(
          att["file"].path,
          filename: att["name"],
        ),
      );
    }

    final formData = FormData.fromMap({
      "attachments[]": files,   // <<<<<<<< IMPORTANT
      "description": description,
    });

    final response = await dio.post(
      postHomeworkUrl,
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
      onSendProgress: (sent, total) {
        setState(() => uploadProgress = sent / total);
      },
    );

    print("📥 RESPONSE: ${response.data}");

    Fluttertoast.showToast(msg: "Homework Submitted Successfully 🎉");

    setState(() {
      descriptionController.clear();
      attachments.clear();
      uploadProgress = 0;
    });
  } catch (e) {
    print("❌ ERROR: $e");
    Fluttertoast.showToast(msg: "Upload Failed");
  } finally {
    setState(() => submitting = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2E3192),
        title: Text(
          "Upload Your Homework",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomNavigationBar: _bottomNav(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 8.w,
            right: 8.w,
            top: 3.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter homework description...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              _uploadUI(),

              if (submitting)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: LinearProgressIndicator(
                    value: uploadProgress,
                    color: Colors.green,
                    minHeight: 1.h,
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attachments.length,
                itemBuilder: (_, i) => _fileCard(attachments[i]),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: submitting ? null : submitHomework,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                  ),
                  child: const Text(
                    "Submit Homework",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadUI() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.h),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF5C61B1)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.upload_rounded, color: Colors.white, size: 40),
          SizedBox(height: 2.h),
          Text(
            "Tap to upload files",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: pickFiles,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              "Browse Files",
              style: TextStyle(color: Color(0xFF2E3192)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileCard(Map file) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.5.h),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(Icons.file_present, color: Colors.grey.shade700),
          SizedBox(width: 3.w),
          Expanded(child: Text(file["name"].toString())),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () {
              attachments.remove(file);
              setState(() {});
              print("🗑 REMOVED FILE: ${file['name']}");
              Fluttertoast.showToast(msg: "File removed");
            },
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2E3192),
      unselectedItemColor: Colors.black54,
      onTap: (i) {
        setState(() => _selectedIndex = i);
        if (i == 0) context.go('/Homepage');
        if (i == 1) context.go('/myactivity');
        if (i == 2) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "My Activities",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile"),
      ],
    );
  }
}
