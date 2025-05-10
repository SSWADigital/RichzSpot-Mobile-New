import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFF60A5FA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color inputText = Color(0xFF9CA3AF);
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color lightBlue = Color(0xFF60A5FA);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF4B5563);
  static const Color textLightGray = Color(0xFF9CA3AF);
  static const Color successGreen = Color(0xFF00C271);
  static const Color warningOrange = Color(0xFFFF8A00);
  static const Color lightBlueBackground = Color(0xFFEEF4FF);
  static const Color progressBackground = Color(0xFFF3F4F6);

  static const double maxWidth = 480.0;
  static const double borderRadius = 16.0;

  static const TextStyle baseText = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient circleGradient = LinearGradient(
    begin: Alignment(-0.5, -0.5),
    end: Alignment(0.5, 0.5),
    colors: [primary, secondary],
    stops: [0.1464, 0.8536],
  );
}
