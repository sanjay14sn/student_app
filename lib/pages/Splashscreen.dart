import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), checkLoginStatus);
  }

  Future<void> checkLoginStatus() async {
    final token = await storage.read(key: "token");
    final expiry = await storage.read(key: "token_expiry");

    if (token == null || expiry == null) {
      if (!mounted) return;
      context.go('/login');
      return;
    }

    try {
      final expiryDate = DateTime.parse(expiry);

      if (DateTime.now().isAfter(expiryDate)) {
        await storage.deleteAll();
        if (!mounted) return;
        context.go('/login');
        return;
      }

      if (!mounted) return;
      context.go('/Homepage');
    } catch (e) {
      await storage.deleteAll();
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3192),
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10.h), // Slightly more top padding

            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      "Sri Sai Tuition Centre", // ⭐ Updated Name
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26.sp, // Increased to 26 (from 24)
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      "A better way to manage your lessons",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16.sp, // Increased to 16 (from 14)
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 32.h, // Adjusted slightly for balance
                  width: 75.w,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(5.w),
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: Image.asset(
                      'assets/images/studentapp1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    "Empowering Students", // More professional footer
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 17.sp, // Increased to 17 (from 15)
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}