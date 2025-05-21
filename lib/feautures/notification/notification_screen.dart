import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import 'widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Back',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notifikasi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  NotificationItem(
                    title: 'New Project Assignment',
                    message: "You've been assigned to Project Aurora",
                    timeAgo: '5 min ago',
                    isUnread: true,
                    iconSvg: '''<svg width="14" height="18" viewBox="0 0 14 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M13.25 7.64258V15.25C13.25 15.7678 13.0669 16.2097 12.7008 16.5758C12.3347 16.9419 11.8928 17.125 11.375 17.125H2.625C2.10723 17.125 1.66529 16.9419 1.29917 16.5758C0.933058 16.2097 0.75 15.7678 0.75 15.25V2.75C0.75 2.23223 0.933058 1.79029 1.29917 1.42417C1.66529 1.05806 2.10723 0.875 2.625 0.875H6.48242C6.64812 0.875025 6.80752 0.906745 6.96061 0.970159C7.1137 1.03357 7.24883 1.12386 7.36602 1.24102L12.884 6.75898C13.0011 6.87617 13.0914 7.0113 13.1548 7.16439C13.2183 7.31748 13.25 7.47688 13.25 7.64258Z" stroke="#4F6BFD" stroke-width="1.25" stroke-linejoin="round"/>
                    </svg>''',
                  ),
                  NotificationItem(
                    title: 'Weekly Report Available',
                    message: 'Q3 performance report is ready to view',
                    timeAgo: '1 hour ago',
                    isUnread: true,
                    iconSvg: '''<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M10 2.5C5.85938 2.5 2.5 5.85938 2.5 10C2.5 14.1406 5.85938 17.5 10 17.5C14.1406 17.5 17.5 14.1406 17.5 10C17.5 5.85938 14.1406 2.5 10 2.5Z" stroke="#9CA3AF" stroke-width="1.25"/>
                      <path d="M10 5V10.625H13.75" stroke="#9CA3AF" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>''',
                  ),
                  NotificationItem(
                    title: 'Meeting Reminder',
                    message: 'Team sync in 30 minutes',
                    timeAgo: '2 hours ago',
                    isUnread: false,
                    iconBackgroundColor: AppColors.border,
                    iconSvg: '''<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M9.6875 2.5C5.71836 2.5 2.5 5.71836 2.5 9.6875C2.5 13.6566 5.71836 16.875 9.6875 16.875C13.6566 16.875 16.875 13.6566 16.875 9.6875C16.875 5.71836 13.6566 2.5 9.6875 2.5Z" stroke="#9CA3AF" stroke-width="1.25"/>
                      <path d="M8.59375 8.59375H9.84375V13.125" stroke="#9CA3AF" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M8.125 13.2812H11.5625" stroke="#9CA3AF" stroke-width="1.25" stroke-linecap="round"/>
                    </svg>''',
                  ),
                  NotificationItem(
                    title: 'System Update',
                    message: 'Platform maintenance scheduled',
                    timeAgo: 'Yesterday',
                    isUnread: false,
                    iconBackgroundColor: AppColors.border,
                    iconSvg: '''<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M9.6875 2.5C5.71836 2.5 2.5 5.71836 2.5 9.6875C2.5 13.6566 5.71836 16.875 9.6875 16.875C13.6566 16.875 16.875 13.6566 16.875 9.6875C16.875 5.71836 13.6566 2.5 9.6875 2.5Z" stroke="#9CA3AF" stroke-width="1.25"/>
                      <path d="M8.59375 8.59375H9.84375V13.125" stroke="#9CA3AF" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M8.125 13.2812H11.5625" stroke="#9CA3AF" stroke-width="1.25" stroke-linecap="round"/>
                    </svg>''',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
