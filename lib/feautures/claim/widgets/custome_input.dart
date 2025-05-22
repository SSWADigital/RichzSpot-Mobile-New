import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppColors.label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            style: AppColors.input,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: AppColors.placeholder,
              prefixIcon: prefix,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
