import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color background = Color(0xFFFFFFFF);
  static const Color textTertiary = Color(0xFF4B5563);
  static const Color borderColor = Color(0xFFF3F4F6);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color pending = Color(0xFFEC4899);
  static const Color inactive = Color(0xFF9CA3AF);
  static const Color cardBackground = Color(0xFFF9FAFB);
  static const Color grey = Color.fromARGB(255, 246, 246, 246);
  static const Color iconBackground = Color.fromARGB(255, 234, 186, 132);
  static const Color iconColor = Color.fromARGB(0, 238, 172, 50);
  static const Color accent = Colors.orangeAccent;
  // static const background = Color(0xFFF9FAFB);
  static const Color text = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);
  // static const white = Color(0xFFFFFFFF);
  static const Color pendingBg = Color(0xFFFFE5CC);
  static const Color pendingText = Color(0xFFB45309);
  static const Color attachmentBg = Color(0xFFF3F4F6);
  static const Color approveBg = Color(0xFFE7F6EC);
  static const Color approveText = Color(0xFF1B5E2F);
  static const Color rejectBg = Color(0xFFFFE5E5);
  static const Color rejectText = Color(0xFFB42318);

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


  // static const Color primaryBlue = Color(0xFF4F6BFD);
  // static const Color textPrimary = Color(0xFF111827);
  // static const Color textSecondary = Color(0xFF6B7280);
  // static const Color textTertiary = Color(0xFF9CA3AF);
  // static const Color borderColor = Color(0xFFF3F4F6);
  static const Color backgroundColor = Colors.white;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: 18,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle timeStyle = TextStyle(
    fontSize: 12,
    color: textTertiary,
    height: 1.5,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 14,
    color: inputText,
    height: 1.5,
  );

  static TextStyle title = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle input = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle placeholder = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.inputText,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

}
