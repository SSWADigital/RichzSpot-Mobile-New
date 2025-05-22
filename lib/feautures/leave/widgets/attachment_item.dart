import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';

class AttachmentItem extends StatelessWidget {
  const AttachmentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.attachmentBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'vacation_plan.pdf',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '245 KB',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () {},
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
