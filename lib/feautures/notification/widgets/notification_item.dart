import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/../../core/constant/app_colors.dart'; 

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final String iconSvg;
  final bool isUnread;
  final VoidCallback? onTap;
  final Color iconBackgroundColor;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.iconSvg,
    this.isUnread = false,
    this.onTap,
    this.iconBackgroundColor = AppColors.iconBackground,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  final Color backgroundColor = isUnread
      ? AppColors.primary.withOpacity(0.1)
      : AppColors.surface;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16), 
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      iconSvg,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
