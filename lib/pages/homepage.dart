import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';

class StudentWorkspace extends StatefulWidget {
  const StudentWorkspace({super.key});

  @override
  State<StudentWorkspace> createState() => _StudentWorkspaceState();
}

class _StudentWorkspaceState extends State<StudentWorkspace> {
  final storage = const FlutterSecureStorage();

  List subjects = [];
  List homework = [];

  bool loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadPage();
  }

  Future<void> loadPage() async {
    await Future.wait([
      fetchSubjects(),
      fetchHomework(),
    ]);

    setState(() => loading = false);
  }

  Future<void> fetchSubjects() async {
    try {
      final token = await storage.read(key: "token");

      final res = await http.get(
        Uri.parse("https://optimista.in/backup/tution/LIstsubjects.php"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        subjects = data["subjects"];
      }
    } catch (_) {}
  }

  Future<void> fetchHomework() async {
    try {
      final token = await storage.read(key: "token");

      final res = await http.get(
        Uri.parse("https://optimista.in/backup/tution/Listhomework.php"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        homework = data["homework"];
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2E3192),
        elevation: 0,
        title: Text(
          "Student Workspace",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/profilepic.png"),
            ),
          )
        ],
      ),

      bottomNavigationBar: _buildBottomNavBar(context),

      body: RefreshIndicator(
        onRefresh: loadPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(3.w),
          child: loading ? _buildShimmerUI() : _buildMainUI(),
        ),
      ),
    );
  }

  // ------------------------------------------
  // SHIMMER UI
  // ------------------------------------------

  Widget _buildShimmerUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 14.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            shimmerBox(width: 30.w, height: 3.h),
            shimmerBox(width: 20.w, height: 3.h),
          ],
        ),

        SizedBox(height: 2.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (_, __) =>
              shimmerBox(width: 100.w, height: 16.h),
        ),

        SizedBox(height: 2.h),

        shimmerBox(width: 40.w, height: 3.h),

        SizedBox(height: 2.h),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) =>
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: shimmerBox(width: 100.w, height: 10.h),
              ),
        ),
      ],
    );
  }

  Widget shimmerBox({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ------------------------------------------
  // MAIN UI — AFTER LOADING
  // ------------------------------------------

  Widget _buildMainUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Box
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3192),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.school,
                  color: Colors.white, size: 36),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  "Welcome back! 👋\nHere’s your learning space",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),

        SizedBox(height: 2.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Subjects",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "${subjects.length} Subjects",
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final s = subjects[index];

            return GestureDetector(
              onTap: () => context.push('/chapters', extra: s),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.book),
                    ),
                    const Spacer(),
                    Text(
                      s["name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: .5.h),
                    Text(
                      "${s["pdfCount"]} PDFs • ${s["videoCount"]} Videos",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        Text(
          "My Homework",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 1.h),

        homework.isEmpty
            ? _emptyBox("No homework assigned 🎉")
            : Column(
                children: homework.map((hw) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Colors.deepPurple.shade50,
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                hw["content"],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: .5.h),
                              Text(
                                "${hw["subject"]}  •  Due: ${hw["dueDate"]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2E3192),
      onTap: (i) {
        setState(() => _selectedIndex = i);
        if (i == 0) context.go('/Homepage');
        if (i == 1) context.go('/myactivity');
        if (i == 2) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.show_chart), label: "Activity"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
