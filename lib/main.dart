import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:student_app/Backend/Gorouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required before async setup

  print("🚀 Starting MY main.dart from /lib");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router, // From Backend/Gorouter.dart
        );
      },
    );
  }
}
