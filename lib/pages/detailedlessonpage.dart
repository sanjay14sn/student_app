import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class ChapterPage extends StatefulWidget {
  final Map<String, dynamic> subjectData;

  const ChapterPage({super.key, required this.subjectData});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  // --- STATIC MOCK DATA GENERATOR ---
  Map<String, List<Map<String, String>>> _getStaticData() {
    return {
      "pdfs": [
        {"title": "Chapter 1: Introduction", "url": "link1.pdf", "size": "1.2 MB"},
        {"title": "Chapter 2: Core Concepts", "url": "link2.pdf", "size": "2.5 MB"},
        {"title": "Revision Notes - Set A", "url": "link3.pdf", "size": "0.8 MB"},
        {"title": "Previous Year Questions", "url": "link4.pdf", "size": "3.1 MB"},
      ],
      "videos": [
        {"title": "Video Lecture 1", "duration": "15:20", "thumbnail": "thumb1"},
        {"title": "Deep Dive: Part A", "duration": "12:45", "thumbnail": "thumb2"},
        {"title": "Problem Solving Session", "duration": "22:10", "thumbnail": "thumb3"},
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _getStaticData();
    final pdfs = data["pdfs"]!;
    final videos = data["videos"]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3192),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          widget.subjectData["name"] ?? "Subject Details",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp, // +2 increase
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "PDFs"),
            Tab(text: "Videos"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildPdfList(pdfs),
          _buildVideoList(videos),
        ],
      ),
    );
  }

  Widget _buildPdfList(List<Map<String, String>> pdfs) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: pdfs.length,
      itemBuilder: (context, i) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade50,
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: Text(
              pdfs[i]["title"]!,
              style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Size: ${pdfs[i]["size"]}",
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54),
            ),
            trailing: Icon(Icons.file_download_outlined, color: Colors.grey, size: 20.sp),
            onTap: () => context.push('/pdf', extra: pdfs[i]),
          ),
        );
      },
    );
  }

  Widget _buildVideoList(List<Map<String, String>> videos) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: videos.length,
      itemBuilder: (context, i) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.play_circle_fill, color: Colors.blue),
            ),
            title: Text(
              videos[i]["title"]!,
              style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Duration: ${videos[i]["duration"]}",
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14.sp),
            onTap: () => context.push('/video', extra: videos[i]),
          ),
        );
      },
    );
  }
}