import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:student_app/Backend/components/pdfview.dart';
import 'package:student_app/Backend/components/video_player_page.dart';
import 'package:student_app/pages/Splashscreen.dart';
import 'package:student_app/pages/detailedlessonpage.dart';
import 'package:student_app/pages/homepage.dart';
import 'package:student_app/pages/loginpage.dart';
import 'package:student_app/pages/myactivities.dart';
import 'package:student_app/pages/profile.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/Homepage', builder: (context, state) => StudentWorkspace()),
    GoRoute(
      path: '/myactivity',
      builder: (context, state) => UploadFilesPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),

    // 🟩 New routes for Subject → Chapter → PDF
 

    GoRoute(
      path: '/chapters',
      builder: (context, state) => ChapterPage(subjectData: state.extra as Map),
    ),

 GoRoute(
  path: '/pdf',
  builder: (context, state) {
    final data = state.extra as Map;

    return PdfViewerPage(
      pdfPath: data["url"] ?? "",   // 👈 NOTE: url not file
      title: data["title"] ?? "",
    );
  },
),
GoRoute(
  path: '/video',
  builder: (context, state) {
    final data = state.extra as Map;

    return VideoPlayerPage(
      videoUrl: data["url"] ?? "",
      title: data["title"] ?? "",
    );
  },
),



  ],
);
