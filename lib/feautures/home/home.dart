import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/fcmserverkey.dart';
import 'package:richzspot/feautures/announcement/screen/announcement_detail_screen.dart';
import 'package:richzspot/feautures/announcement/service/announcment_service.dart';
import 'package:richzspot/feautures/face_recognation/service/absen_servicel.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';

import '../../main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _navTitles = ['Menu Utama', 'RichzCRM'];

  // Daftar widget untuk setiap halaman
  List<Widget> get _pages => <Widget>[
    _buildGridSection(),
    _buildRichzCRMGridSection(),
    // const Center(child: Text('Halaman Tagihan', style: TextStyle(fontSize: 18, color: Colors.grey))),
    // const Center(child: Text('Halaman Asuransi', style: TextStyle(fontSize: 18, color: Colors.grey))),
  ];

List<Map<String, dynamic>> announcements = [];
  var userData;

  Map<String, dynamic> _absenData = {
    'checkin': '-',
    'checkout': '-',
    'status': '0',
  };

  final AbsenService _absenService = AbsenService();
  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerIndex = 0;
  bool _isLoading = true;

   @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

    @override
    void initState() {
      super.initState();
      getUserData();
      
    //   _setupForegroundMessageListener();
    // _handleInitialMessage();
      
    }

  Future<void> getUserData() async {
  final data = await AppStorage.getUser();
  setState(() {
    userData = data;
    // print("user Id: ${userData['id_role']}");
    _loadAnnouncements();
    _checkTodayAttendance();
  });
}

  //   void _setupForegroundMessageListener() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Got a message whilst in the foreground!');
  //     print('Message data: ${message.data}');

  //     if (message.notification != null) {
  //       print('Message also contained a notification: ${message.notification}');
  //       _showLocalNotification(message); // Show local notification in foreground
  //     }
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('Message opened app: ${message.data}');
  //     _handleNavigation(message);
  //   });
  // }

  // Future<void> _handleInitialMessage() async {
  //   final RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();

  //   if (initialMessage != null) {
  //     _handleNavigation(initialMessage);
  //   }
  // }

  // void _handleNavigation(RemoteMessage message) {
  //   if (message.data['route'] != null) {
  //     Navigator.pushNamed(context, message.data['route']);
  //   }
  // }

  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   final AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'button_channel_id', // Replace with your channel ID
  //     'Button Triggered Notifications', // Replace with your channel name
  //     channelDescription: 'Notifications triggered by a button in the app',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );

  //   final NotificationDetails platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: const DarwinNotificationDetails());

  //   await flutterLocalNotificationsPlugin.show(
  //     0, // Notification ID (can be unique for each notification)
  //     message.notification?.title ?? 'Test Notification Title', // Default title
  //     message.notification?.body ?? 'This is a test notification triggered by a button!', // Default body
  //     platformChannelSpecifics,
  //     payload: message.data['route'], // Optional payload for navigation
  //   );
  // }

  // // Function to trigger a local notification directly
  // Future<void> _triggerLocalNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'button_channel_id', // Different channel ID for button-triggered notifications
  //     'Button Triggered Notifications',
  //     channelDescription: 'Notifications triggered by a button in the app',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: DarwinNotificationDetails());
  //   await flutterLocalNotificationsPlugin.show(
  //     1, // Different notification ID
  //     'Button Notification',
  //     'This notification was triggered by pressing a button!',
  //     platformChannelSpecifics,
  //     payload: 'button_payload', // Optional payload
  //   );

  //   final get = GetFcmServerKey();
  //   get.serverToken().then((value) {
  //     print('Server Token: $value');
  //   });
  // }

 Future<void> _sendNotification() async {
    NotificationService notificationService = NotificationService();
    String? token = await AppStorage.getFCMDeviceToken();
    String? serverToken = await AppStorage.getFCMServerToken();
    String? platform = await AppStorage.getPlatform();
    
    notificationService.sendFcmNotificationV1(
      userId: userData['user_id'],
      recipientToken: token ?? '',
      type: 'test',
      action: 'testing action',
      menu: 'testing menu',
      additionalData: {
        'key1': 'value1',
        'key2': 'value2',
      },
      // serverToken: serverToken,
      // platform: platform,
      title: 'Test Notification',
      body: 'This is a test notification triggered by a button! ${userData['user_nama_lengkap']}',
    );
  }

    Future<void> _checkTodayAttendance() async {
    if (userData == null || userData['user_id'] == null || !mounted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _absenService.cekAbsen();

      
      if (mounted) {
        setState(() {
          _absenData = {
            'checkin': response.checkin,
            'checkout': response.checkout,
            'status': response.status,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error checking attendance: $e');
      }
    }
  }

 Future<void> _loadAnnouncements() async {
    if (userData != null && userData['id_departemen'] != null) {
      try {
        final data = await AnnouncementService.getAnnouncementsByDepartment(userData['id_departemen']);
        setState(() {
          announcements = data;
        });
      } catch (e) {
        // Redirect to sign in if Unauthorized
        if (e.toString().contains('Unauthorized')) {
          Navigator.pushReplacementNamed(context, AppRoutes.sign);
        } else {
          print('Error loading announcements: $e');
          // Optionally show a snackbar or error message to the user
        }
        // Handle error loading announcements
        // print('Error loading announcements: $e');
        // Optionally show a snackbar or error message to the user
      }
    }
  }

Widget _buildHeader(var userData) {
  // Format tanggal hari ini
  final now = DateTime.now();
  final todayFormatted = DateFormat('EEEE • d MMMM', 'id_ID').format(now);

  return Stack(
    clipBehavior: Clip.none, // Allow child to overflow the Stack
    children: [
      // Bagian Header Biru
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Text('${userData['user_nama_lengkap']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${userData['role_nama']}',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            // Foto profil bulat
            ClipOval(
              child: Image.network(
                '${userData['user_foto']}',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),

      // Container untuk Check-in/Check-out yang menimpa header
      Positioned(
        top: 135, // Sesuaikan nilai ini untuk mengatur seberapa banyak tumpang tindih
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
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
                    todayFormatted, // Menggunakan tanggal hari ini yang diformat
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: AppColors.textGray, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '08:00 - 16:30',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
}// Widget _buildTimeTrackingSection() {

  //   return 
  // }
 Widget _buildAnnouncementBanner() {
    if (announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: announcements.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return GestureDetector( // Wrap the banner in a GestureDetector
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailScreen(announcement: announcement),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (announcement['berita_foto'] != null && announcement['berita_foto'].isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: announcement['berita_foto'],
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white),
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement['berita_judul'] ?? 'Announcement',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (announcement['berita_keterangan'] != null && announcement['berita_keterangan'].isNotEmpty)
                              Text(
                                announcement['berita_keterangan'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (announcements.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: announcements.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == entry.key ? AppColors.primary : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

Widget _buildCheckInBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.login, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text('CHECK IN', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading ? '...' : _absenData['checkin'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.logout, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text('CHECK OUT', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading ? '...' : _absenData['checkout'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
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

  Widget _buildNavButton({required int index, required String title}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      // Hilangkan efek splash default karena sudah ada feedback dari perubahan warna
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        // Ubah state saat tombol ditekan
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

Widget _buildGridSection() {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGridItem('assets/icon/1.png', AppRoutes.attendance, 'Attendance',),
            _buildGridItem('assets/icon/4.png', AppRoutes.activity, 'Activity'),
            _buildGridItem('assets/icon/3.png', AppRoutes.leave, 'Leave'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGridItem('assets/icon/2.png', AppRoutes.timeOff, 'Time Off'),

            _buildGridItem('assets/icon/5.png', AppRoutes.overtime, 'Overtime'),
            // _buildGridItem('assets/icon/6.png', AppRoutes.claim, 'Claim'),
            _buildGridItem('assets/icon/8.png', AppRoutes.payslip, 'Payslip'),
            // _buildGridItem('assets/icon/9.png', AppRoutes.more, 'More'),
          ],
        ),
        const SizedBox(height: 16),
        if(userData['id_role'] != "4") ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGridItem('assets/icon/3.png', AppRoutes.leaveApproval, 'Appv Leave'),
              _buildGridItem('assets/icon/2.png', AppRoutes.timeOffApproval, 'Appv Time Off'),
              _buildGridItem('assets/icon/5.png', AppRoutes.overtimeApproval, 'Appv Overtime'),
              // _buildGridItem('assets/icon/8.png', AppRoutes.paySlipApproval, 'Appv Payslip'),
              // _buildGridItem('assets/icon/11.png', AppRoutes.announcement, 'Announcement'),
              // _buildGridItem('assets/icon/12.png', AppRoutes.chat, 'Chat'),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildRichzCRMGridSection() {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGridItem('assets/icon/tickets.png', AppRoutes.crmTickets, 'Tickets'),
            _buildGridItem('assets/icon/programmer.png', AppRoutes.crmProgrammer, 'Proggrammer'),
            _buildGridItem('assets/icon/tasklist.png', AppRoutes.crmTasklist, 'Tasklist'),
          ],
        ),
        // const SizedBox(height: 16),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     _buildGridItem('assets/icon/2.png', AppRoutes.crmContacts, 'Contacts'),
        //     _buildGridItem('assets/icon/5.png', AppRoutes.crmAccounts, 'Accounts'),
        //     _buildGridItem('assets/icon/8.png', AppRoutes.crmTasks, 'Tasks'),
        //   ],
        // ),
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
                _buildKPIItem('Target', 85, AppColors.primaryBlue),
                _buildKPIItem('Work Time', 90, AppColors.successGreen),
                _buildKPIItem('Task', 82, AppColors.warningOrange),
                _buildKPIItem('AVG', 88, AppColors.primaryBlue),
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
              SizedBox(
                height: 150,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // _buildTimeTrackingSection(),
                    _buildAnnouncementBanner(),
              // _buildChartImage(),
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                _navTitles.length,
                (index) => _buildNavButton(
                  index: index,
                  title: _navTitles[index],
                ),
              ),
            ),
          ),
          Column(
            children: [_pages.elementAt(_selectedIndex)],
          ),
              // _buildGridSection(),
              // _buildKPISection(),
            //   ElevatedButton(
            //   onPressed: _sendNotification,
            //   child: const Text('Trigger Local Notification'),
            // ),
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
}
