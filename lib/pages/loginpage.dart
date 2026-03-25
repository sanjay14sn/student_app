import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> pinFocusNodes = List.generate(4, (_) => FocusNode());

  final storage = const FlutterSecureStorage();
  bool loading = false;

  // Helper to get full 4-digit PIN string
  String get fullPin => pinControllers.map((c) => c.text).join();

  void showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  Future<void> handleLogin() async {
    final mobile = mobileController.text.trim();
    final pin = fullPin.trim();

    // 1. Validation
    if (mobile.length != 10 || pin.length != 4) {
      showToast("Enter 10-digit mobile & 4-digit PIN", Colors.redAccent);
      return;
    }

    setState(() => loading = true);

    // 2. Hardcoded Test Login Logic
    if (mobile == "7868000645" && pin == "1234") {
      await _processSuccessfulLogin({
        "token": "test_token_123",
        "student_id": "STU001",
        "student_name": "Sanjay Naveen",
        "token_expiry": "2026-12-31"
      });
      return;
    }

    // 3. Actual API Login Logic
    try {
      final response = await http.post(
        Uri.parse("https://optimista.in/backup/tution/Login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobileNumber": mobile, "pin": pin}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        await _processSuccessfulLogin(data["data"]);
      } else {
        showToast(data["message"] ?? "Invalid Credentials", Colors.redAccent);
      }
    } catch (e) {
      showToast("Connection Error. Check internet.", Colors.orange);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _processSuccessfulLogin(Map<String, dynamic> userData) async {
    await storage.write(key: "token", value: userData["token"]);
    await storage.write(key: "student_id", value: userData["student_id"]);
    await storage.write(key: "student_name", value: userData["student_name"]);
    
    showToast("Welcome ${userData["student_name"]}", Colors.green);
    if (mounted) context.go('/Homepage');
  }

  @override
  void dispose() {
    mobileController.dispose();
    for (var controller in pinControllers) {
      controller.dispose();
    }
    for (var node in pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Column(
            children: [
              SizedBox(height: 6.h),
              Text("Login",
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3192))),
              SizedBox(height: 4.h),
              SizedBox(height: 22.h, child: Image.asset('assets/images/new.png')),
              SizedBox(height: 5.h),

              // Mobile Input
              _buildWhiteCard(
                child: TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.phone_android, color: Colors.black54),
                    suffixIcon: const Icon(Icons.phone_android, color: Colors.transparent),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // PIN Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildPinBox(index)),
              ),

              SizedBox(height: 5.h),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: loading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.5.h)),
                  ),
                  child: loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Sign In", style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(2.h),
      color: Colors.white,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 2.w), child: child),
    );
  }

  Widget _buildPinBox(int index) {
    return SizedBox(
      width: 15.w,
      child: TextField(
        controller: pinControllers[index],
        focusNode: pinFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black12), borderRadius: BorderRadius.circular(1.h)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2), borderRadius: BorderRadius.circular(1.h)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(pinFocusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(pinFocusNodes[index - 1]);
          }
        },
      ),
    );
  }
}