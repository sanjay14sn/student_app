import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ChapterPage extends StatefulWidget {
  final Map subjectData;

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

  @override
  Widget build(BuildContext context) {
    final pdfs = widget.subjectData["pdfs"];
    final videos = widget.subjectData["videos"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3192),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          widget.subjectData["name"],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "PDFs"),
            Tab(text: "Videos"),
          ],
        ),
      ),

      body: TabBarView(
        controller: tabController,
        children: [
          /// PDFs LIST
          ListView.builder(
            itemCount: pdfs.length,
            itemBuilder: (context, i) {
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(pdfs[i]["title"]),
                onTap: () {
                  context.push('/pdf', extra: pdfs[i]); // 👈 SEND MAP
                },
              );
            },
          ),

          /// VIDEOS LIST
          ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, i) {
              return ListTile(
                leading: const Icon(Icons.play_circle_fill, color: Colors.blue),
                title: Text(videos[i]["title"]),
                onTap: () {
                  context.push('/video', extra: videos[i]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
