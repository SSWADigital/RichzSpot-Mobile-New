import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation.dart';
import 'package:richzspot/feautures/home/home_staff.dart';
import 'package:richzspot/feautures/notification/screen/notification_screen.dart';
import 'package:richzspot/feautures/profile/profile_screen.dart';
import 'package:richzspot/feautures/schedule/screen/schedule_screen.dart';

class AppStaffScreen extends StatefulWidget {
  const AppStaffScreen({super.key});

  @override
  State<AppStaffScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppStaffScreen> {
  int _currentIndex = 0;
  

  final List<Widget> _pages = [
    HomeStaffScreen(),
    NotificationScreen(),
    FaceScanner(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(45, 0, 0, 0),
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNotificationNavItem(Icons.notifications, 'Notification', 1),
          _buildCenterActionButton(2),
          _buildNavItem(Icons.calendar_today, 'Schedule', 3),
          _buildNavItem(Icons.person, 'Account', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryBlue : AppColors.textLightGray,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppColors.primaryBlue : AppColors.textLightGray,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primaryBlue : AppColors.textLightGray,
                size: 24,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppColors.primaryBlue : AppColors.textLightGray,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterActionButton(int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.login,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
