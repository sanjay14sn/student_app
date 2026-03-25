import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';

class StudentWorkspace extends StatefulWidget {
  const StudentWorkspace({super.key});

  @override
  State<StudentWorkspace> createState() => _StudentWorkspaceState();
}

class _StudentWorkspaceState extends State<StudentWorkspace> {
  bool loading = true;
  int _selectedIndex = 0;

  // --- STATIC MOCK DATA ---
  final List<Map<String, dynamic>> subjects = [
    {"name": "Mathematics", "pdfCount": 12, "videoCount": 8, "icon": Icons.calculate, "color": Colors.orange},
    {"name": "Science", "pdfCount": 15, "videoCount": 10, "icon": Icons.biotech, "color": Colors.green},
    {"name": "English", "pdfCount": 8, "videoCount": 5, "icon": Icons.translate, "color": Colors.blue},
    {"name": "History", "pdfCount": 5, "videoCount": 3, "icon": Icons.history_edu, "color": Colors.brown},
  ];

  final List<Map<String, dynamic>> homework = [
    {"content": "Algebra Exercise 4.2", "subject": "Mathematics", "dueDate": "Oct 25", "status": "Pending"},
    {"content": "Photosynthesis Diagram", "subject": "Science", "dueDate": "Oct 26", "status": "Pending"},
    {"content": "Essay on Shakespeare", "subject": "English", "dueDate": "Oct 28", "status": "Pending"},
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => loading = false);
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
            fontSize: 18.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'), // ⭐ Profile Tap
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 22,
                child: Icon(Icons.person, color: Colors.white, size: 22.sp),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => loading = true);
          _simulateLoading();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: loading ? _buildShimmerUI() : _buildMainUI(),
        ),
      ),
    );
  }

  // ------------------------------------------
  // MAIN UI
  // ------------------------------------------

  Widget _buildMainUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E3192), Color(0xFF4E54C8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_stories, color: Colors.white, size: 44),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  "Welcome back! 👋\nYou have 3 tasks today.",
                  style: GoogleFonts.poppins(
                    color: Colors.white, 
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              )
            ],
          ),
        ),

        SizedBox(height: 3.h),

        _sectionHeader("My Subjects", "${subjects.length} Total"),
        SizedBox(height: 1.5.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final s = subjects[index];
            return _subjectCard(s);
          },
        ),

        SizedBox(height: 3.h),

        _sectionHeader("My Homework", "This Week"),
        SizedBox(height: 1.5.h),

        ...homework.map((hw) => _homeworkCard(hw)).toList(),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        Text(subtitle, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14.sp)),
      ],
    );
  }

  Widget _subjectCard(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => context.push('/chapters', extra: s), // ⭐ Subject Card Tap
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: (s["color"] as Color).withOpacity(0.1),
              child: Icon(s["icon"], color: s["color"], size: 20.sp),
            ),
            const Spacer(),
            Text(s["name"], style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15.sp)),
            Text("${s["pdfCount"]} PDFs • ${s["videoCount"]} Videos",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget _homeworkCard(Map<String, dynamic> hw) {
    return GestureDetector(
      // ⭐ Navigation logic implemented here
      onTap: () => context.push('/homework-detail', extra: hw), 
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50, 
                shape: BoxShape.circle
              ),
              child: Icon(Icons.assignment_outlined, color: Colors.deepPurple, size: 20.sp),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hw["content"], 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)
                  ),
                  Text(
                    "${hw["subject"]} • Due ${hw["dueDate"]}",
                    style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13.sp)
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  // ------------------------------------------
  // SHIMMER UI
  // ------------------------------------------

  Widget _buildShimmerUI() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          SizedBox(height: 4.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(height: 3.5.h, width: 35.w, color: Colors.white),
            Container(height: 3.5.h, width: 25.w, color: Colors.white),
          ]),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
            itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2E3192),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11.sp),
      onTap: (i) {
        setState(() => _selectedIndex = i);
        // ⭐ Navigation logic restored
        if (i == 0) context.go('/Homepage');
        if (i == 1) context.go('/myactivity');
        if (i == 2) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Activity"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}