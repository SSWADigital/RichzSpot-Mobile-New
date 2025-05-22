import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class HomeStaffScreen extends StatefulWidget {
  const HomeStaffScreen({super.key});


  @override
  State<HomeStaffScreen> createState() => HomeStaffScreenState();

}

class HomeStaffScreenState extends State<HomeStaffScreen> {

  var userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
  final data = await AppStorage.getUser();
  setState(() {
    userData = data;
  });
}


  @override
  Widget build(BuildContext context) {

     if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
          color: Colors.blueAccent,
        )),
      );
    }

    return 
    SafeArea(
      child:   Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          // constraints: const BoxConstraints(maxWidth: 480),
          // margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildHeader(userData),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // _buildTimeTrackingSection(),
              _buildChartImage(),
              _buildGridSection(),
              _buildKPISection(),
              // _buildBottomNavigation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigation(),
    ),
    );
  
  }

Widget _buildHeader(var userData) {
  return Column(
    children: [
      // Bagian Header Biru
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.lightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info pengguna
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${userData['departemen_nama']}',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${userData['user_nama_lengkap']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${userData['role_nama']}',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            // Foto profil bulat
            ClipOval(
              child: Image.network(
                '${userData['user_foto']}',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),

      Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Baris atas: tanggal & jam kerja
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today • 7 Mei 2025',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: AppColors.textGray, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '08:00 - 16:30',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Baris bawah: box check-in dan check-out
              Row(
                children: [
                  Expanded(child: _buildCheckInBox()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCheckOutBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  // Widget _buildTimeTrackingSection() {
  //   return 
  // }

Widget _buildCheckInBox() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.login,
            color: AppColors.successGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHECK IN',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '07:35:07',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCheckOutBox() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.logout,
            color: AppColors.warningOrange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHECK OUT',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '18:05:07',
              style: TextStyle(
                color: AppColors.warningOrange,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildChartImage() {
    return Container(
      margin: const EdgeInsets.only(top: 21),
      child: Image.network(
        'https://cdn.builder.io/api/v1/image/assets/TEMP/db03c42e9b18d8533479ad7282e002984b68f8ff?placeholderIfAbsent=true&apiKey=f98f93bc0b6c4ec1ad8e8e21245a1bea',
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

Widget _buildGridSection() {
  return Container(
    margin: const EdgeInsets.only(top: 48),
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGridItem('assets/icon/1.png', AppRoutes.attendance, 'Attendance',),
            _buildGridItem('assets/icon/2.png', AppRoutes.activity, 'Activity'),
            _buildGridItem('assets/icon/3.png', AppRoutes.leaveApproval, 'Appv Leave'),
            _buildGridItem('assets/icon/4.png', AppRoutes.assignment, 'Assignment'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGridItem('assets/icon/5.png', AppRoutes.overtime, 'Overtime'),
            _buildGridItem('assets/icon/6.png', AppRoutes.claim, 'Claim'),
            _buildGridItem('assets/icon/8.png', AppRoutes.payslip, 'Payslip'),
            _buildGridItem('assets/icon/9.png', AppRoutes.more, 'More'),
          ],
        ),
      ],
    ),
  );
}

Widget _buildGridItem(String assetPath, String route, [String? label]) {
  return 
  GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, route);
    },
    child:   Column(
    children: [
      Image.asset(
        assetPath,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      ),
      if (label != null) ...[
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ],
    ],
  ),
  );

}

  Widget _buildKPISection() {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KPI',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildKPIItem('Lorem', 85, AppColors.primaryBlue),
                _buildKPIItem('Ipsum', 90, AppColors.successGreen),
                _buildKPIItem('Dorom', 82, AppColors.warningOrange),
                _buildKPIItem('Siptamo', 88, AppColors.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIItem(String label, int percentage, Color progressColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
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
          offset: const Offset(0, -1),
          blurRadius: 10,
        ),
      ],
    // ),
      // boxShadow: 
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavItem(Icons.home, 'Home', true),
        _buildNotificationNavItem(Icons.notifications, 'Notification', false),
        _buildCenterActionButton(),
        _buildNavItem(Icons.calendar_today, 'Schedule', false),
        _buildNavItem(Icons.person, 'Account', false),
      ],
    ),
  );
}


Widget _buildNavItem(IconData icon, String label, bool isActive) {
  return Column(
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
          color: isActive ? AppColors.primaryBlue : AppColors.textLightGray,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    ],
  );
}

Widget _buildNotificationNavItem(IconData icon, String label, bool isActive) {
  return Column(
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
              decoration: BoxDecoration(
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
          color: isActive ? AppColors.primaryBlue : AppColors.textLightGray,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    ],
  );
}

Widget _buildCenterActionButton() {
  return Container(
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
  );
}

  

}
