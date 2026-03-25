import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> homeworkData;

  const HomeworkDetailPage({super.key, required this.homeworkData});

  @override
  Widget build(BuildContext context) {
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
          "Assignment Detail",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Status Badge ---
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: homeworkData["status"] == "Pending" 
                    ? Colors.orange.shade100 
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                homeworkData["status"] ?? "Pending",
                style: GoogleFonts.poppins(
                  color: homeworkData["status"] == "Pending" 
                      ? Colors.orange.shade900 
                      : Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            
            SizedBox(height: 3.h),

            // --- Title & Subject ---
            Text(
              homeworkData["content"] ?? "No Title",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E3192),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Subject: ${homeworkData["subject"]}",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            Divider(height: 5.h, thickness: 1),

            // --- Info Grid ---
            Row(
              children: [
                _infoCard(Icons.calendar_month, "Due Date", homeworkData["dueDate"]),
                SizedBox(width: 4.w),
                _infoCard(Icons.query_builder, "Time", "11:59 PM"),
              ],
            ),

            SizedBox(height: 4.h),

            // --- Description ---
            Text(
              "Instructions",
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              "Please complete the exercises from Page 45 to 50 in your textbook. Ensure you show all your working out for the algebra problems. Once completed, take a clear photo of your work and upload it using the button below.",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.6,
              ),
            ),

            SizedBox(height: 6.h),

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "Submission feature coming soon!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Submit Assignment",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2E3192), size: 22.sp),
            SizedBox(height: 1.h),
            Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54)),
            Text(value, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}