import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppRoutes.navigatorKey.currentState != null && !navigatorStateCompleter.isCompleted) {
        print("✅ Navigator is ready, completing the completer.");
        navigatorStateCompleter.complete(AppRoutes.navigatorKey.currentState);
      } else if (AppRoutes.navigatorKey.currentState == null && !navigatorStateCompleter.isCompleted) {
        // Fallback if still null (less likely if key is correctly assigned to MaterialApp)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (AppRoutes.navigatorKey.currentState != null && !navigatorStateCompleter.isCompleted) {
            print("✅ Navigator is ready (after delay), completing the completer.");
            navigatorStateCompleter.complete(AppRoutes.navigatorKey.currentState);
          } else if (!navigatorStateCompleter.isCompleted) {
            print("⚠️ COMPLETER: Navigator still null in SplashScreen. Notification navigation on cold start might be affected.");
            // Consider completing with an error if critical:
            // navigatorStateCompleter.completeError(StateError("Navigator not ready from SplashScreen"));
          }
        });
      }
    });

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