import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color dotColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending approval':
        backgroundColor = const Color(0xFFFDF2F8);
        dotColor = AppColors.pending;
        textColor = AppColors.pending;
        break;
      case 'approved':
        backgroundColor = const Color(0xFFF0FDF4);
        dotColor = AppColors.success;
        textColor = AppColors.success;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFEF2F2);
        dotColor = AppColors.error;
        textColor = AppColors.error;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        dotColor = Colors.grey;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 20/14,
            ),
          ),
        ],
      ),
    );
  }
}
