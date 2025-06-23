import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/fcmserverkey.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation.dart';
import 'package:richzspot/feautures/home/home.dart';
import 'package:richzspot/feautures/notification/screen/notification_screen.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:richzspot/feautures/profile/profile_screen.dart';
import 'package:richzspot/feautures/schedule/screen/schedule_screen.dart';
import 'package:richzspot/main.dart';
import 'package:fluttertoast/fluttertoast.dart' as flutter_toast;
import 'package:in_app_update/in_app_update.dart';

final Completer<NavigatorState> navigatorStateCompleter = Completer<NavigatorState>();
class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _currentIndex = 0;
  final _notificationService = NotificationService();
  List<dynamic> _allNotifications = [];
  int _unreadNotificationCount = 0;
  DateTime? _lastBackPressed;
  final Completer<void> _updateCheckCompleter = Completer<void>();

   Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Update is available
        if (updateInfo.immediateUpdateAllowed) {
          // Perform an immediate update (user must update to proceed)
          print('Immediate update available. Starting update...');
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform a flexible update (user can choose to update later)
          print('Flexible update available. Starting flexible update...');
          await InAppUpdate.startFlexibleUpdate();
          // Listen for flexible update completion
          InAppUpdate.completeFlexibleUpdate().then((_) {
            print('Flexible update downloaded and installed!');
            showSimpleNotification(
              const Text("Update Selesai! Aplikasi akan restart."),
              background: AppColors.primary,
              position: NotificationPosition.bottom,
            );
          }).catchError((e) {
            print('Failed to complete flexible update: $e');
            showSimpleNotification(
              Text("Gagal menginstal update: $e"),
              background: Colors.red,
              position: NotificationPosition.bottom,
            );
          });
        }
      } else {
        print('No update available.');
      }
    } catch (e) {
      print('Failed to check for updates: $e');
      // Handle error (e.g., show a toast message)
      showSimpleNotification(
        Text("Gagal memeriksa update: $e"),
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
    }
  }

  Future<void> _fetchNotifications() async {
   
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _allNotifications = notifications;
      // print('Notifications: ${jsonEncode(_allNotifications)}');
      // _unreadNotificationCount = _allNotifications.where((notif) => !(notif['is_read'] ?? true)).length;

      _unreadNotificationCount = _allNotifications.where((notif) {
        // Pastikan kita menangani `is_read` sebagai boolean
        final bool isRead = notif.isRead;
            // ? notif['is_read']
            // : (notif['is_read'] == 'true'); // Konversi string 'true'/'false' ke boolean

        return !isRead; // Hanya hitung yang `false`
      }).length;
    });
  }


  // void _setupForegroundMessageListener() {
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
  //           'your_channel_id', // Replace with your channel ID
  //           'your_channel_name', // Replace with your channel name
  //           channelDescription: 'your_channel_description',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           ticker: 'ticker');

  //   final NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics, iOS: const DarwinNotificationDetails());

  //   await flutterLocalNotificationsPlugin.show(
  //     0, // Notification ID
  //     message.notification?.title,
  //     message.notification?.body,
  //     platformChannelSpecifics,
  //     payload: message.data['route'],
  //   );
  // }

  @override
  void dispose() {
    notificationTypeNotifier.removeListener(_handleNotificationRefresh);

    super.dispose();
  }

  

  @override
  void initState() {
    super.initState();

    // Future.delayed(const Duration(seconds: 2), () {
    //   _checkForUpdate();
    //   _updateCheckCompleter.complete();
    // });

    notificationTypeNotifier.removeListener(_handleNotificationRefresh);
    // _getFcmAccessToken();

    _fetchNotifications();
    // _setupForegroundMessageListener();
    // _handleInitialMessage();
  }

  void _handleNotificationRefresh() {
    setState(() {
    print('AppScreen initialized');

      _fetchNotifications();
    });
  }

   Future<void> _getFcmAccessToken() async {
    print("Memulai proses untuk mendapatkan FCM Access Token...");
    final fcmService = GetFcmServerKey();
    final token = await fcmService.serverToken();
    
    if (token != null) {
      print("FCM Access Token berhasil didapatkan di initState.");
      print("FCM Access Token: $token");
      // Anda bisa menyimpan token ini di state atau service lain jika perlu,
      // tapi ingat, ini hanya berlaku sekitar 1 jam.
    } else {
      print("Gagal mendapatkan FCM Access Token di initState.");
    }
  }

  
  

  final List<Widget> _pages = [
    HomeScreen(),
    NotificationScreen(),
    FaceScanner(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // --- AWAL PERUBAHAN: Bungkus Scaffold dengan PopScope ---
    return PopScope(
      // canPop: false berarti kita akan menangani tombol kembali secara manual
      canPop: false,
      // onPopInvoked akan dipanggil setiap kali ada upaya untuk "pop" (kembali)
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }

        final now = DateTime.now();
        // Cek jika tombol kembali belum pernah ditekan, atau
        // jika jeda antara tekanan pertama dan kedua lebih dari 2 detik
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          
          // Simpan waktu tekanan pertama
          _lastBackPressed = now;

          // Tampilkan toast
          flutter_toast.Fluttertoast.showToast(
            msg: "Tekan sekali lagi untuk keluar",
            toastLength: flutter_toast.Toast.LENGTH_SHORT,
            gravity: flutter_toast.ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          // Jika tekanan kedua terjadi dalam 2 detik, tutup aplikasi
          flutter_toast.Fluttertoast.cancel(); // Batalkan toast yang mungkin masih muncul
          SystemNavigator.pop(); // Keluar dari aplikasi
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _pages[_currentIndex],
          bottomNavigationBar: _buildBottomNavigation(),
        ),
      ),
    );
    // --- AKHIR PERUBAHAN ---
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
          _buildNotificationNavItem(Icons.notifications, 'Notifications', 1),
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

  // Tentukan apakah badge harus ditampilkan untuk ikon notifikasi
  // dan apakah ada notifikasi yang belum dibaca
  final bool showBadgeWithCount = (label == 'Notifications' && _unreadNotificationCount > 0);

  return GestureDetector(
    onTap: () {
      setState(() {
        _currentIndex = index;
        // Jika tab notifikasi diklik, refresh data (atau tandai semua sudah dibaca jika sesuai alur)
        if (label == 'Notifications') {
          _fetchNotifications(); // Refresh untuk update badge
        }
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none, // Penting agar badge tidak terpotong
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBlue : AppColors.textLightGray,
              size: 24,
            ),
            // Hanya tampilkan badge jika showBadgeWithCount adalah true
            if (showBadgeWithCount)
              Positioned(
                // Sesuaikan posisi agar menempel ke ikon
                right: -4, // Eksperimen dengan nilai ini
                top: -4,  // Eksperimen dengan nilai ini
                child: Container(
                  padding: const EdgeInsets.all(1.5), // Padding di dalam badge
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    // border: Border.all(color: Colors.white, width: 1.5), // Border putih agar lebih terlihat
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14, // Ukuran minimum badge
                    minHeight: 14,
                  ),
                  child: Center(
                    child: Text(
                      // Tampilkan count, jika lebih dari 99, tampilkan '99+'
                      _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Ukuran font untuk angka
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
