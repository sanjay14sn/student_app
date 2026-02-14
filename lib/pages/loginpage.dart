import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add this to pubspec.yaml

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> pinControllers =
      List.generate(4, (_) => TextEditingController());

  final storage = const FlutterSecureStorage();
  bool loading = false;

  String get pin => pinControllers.map((controller) => controller.text).join();

  // Helper function for Toast
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

  Future<void> loginUser() async {
    if (mobileController.text.isEmpty || pin.length != 4) {
      showToast("Please enter valid details", Colors.redAccent);
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("https://optimista.in/backup/tution/Login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobileNumber": mobileController.text.trim(),
          "pin": pin.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        final user = data["data"];
        await storage.write(key: "token", value: user["token"]);
        await storage.write(key: "student_id", value: user["student_id"]);
        await storage.write(key: "student_name", value: user["student_name"]);
        await storage.write(key: "token_expiry", value: user["token_expiry"]);

        showToast("Login Successful", Colors.green);
        if (mounted) context.go('/Homepage');
      } else {
        showToast("Login Failed: Invalid Credentials", Colors.redAccent);
      }
    } catch (e) {
      showToast("Server Error. Try again later.", Colors.orange);
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E3192),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(height: 26.h, child: Image.asset('assets/images/login1.png')),
              SizedBox(height: 4.h),

              /// 📱 Mobile Field - White background & Centered
              Material(
                elevation: 3,
                color: Colors.white, // ⭐ Ensures the field is white
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(2.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: TextField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center, // ⭐ Centers the input number
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Enter Mobile Number",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                      // Prefix/Suffix icons balance each other to keep text centered
                      prefixIcon: Icon(Icons.phone_android, color: Colors.black54),
                      suffixIcon: const Icon(Icons.phone_android, color: Colors.transparent),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              /// 🔐 4-Digit PIN Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 15.w,
                    child: TextField(
                      controller: pinControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      obscureText: true,
                      style: TextStyle(fontSize: 18.sp),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.h),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: 5.h),

              /// 🔵 Login Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: loading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.h)),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}