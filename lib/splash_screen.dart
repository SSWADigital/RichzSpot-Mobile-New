import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainScreen();
  }

  Future<void> _navigateToMainScreen() async {
    // Simulate a delay for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await AppStorage.isLoggedIn();

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? AppRoutes.appRoot : AppRoutes.sign,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icon/splash.gif',
          gaplessPlayback: true, // Untuk animasi GIF yang lebih mulus
        ),
      ),
    );
  }
}