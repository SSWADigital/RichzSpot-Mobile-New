import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';

class CustomTextArea extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;

  const CustomTextArea({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppColors.label),
        const SizedBox(height: 8),
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: AppColors.input,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: AppColors.placeholder,
            ),
          ),
        ),
      ],
    );
  }
}
