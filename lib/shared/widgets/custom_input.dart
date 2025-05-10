import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
// import '../theme/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String placeholder;
  final bool isPassword;
  final IconData icon;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.placeholder,
    this.isPassword = false,
    required this.icon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.inputText,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.inputText,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                color: AppColors.inputText,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
