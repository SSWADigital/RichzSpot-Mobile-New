import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:richzspot/app.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/attendance/screen/attendance_screen.dart';
import 'package:richzspot/feautures/auth/screen/sign_screen.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation_register.dart';
import 'package:richzspot/feautures/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'splash_screen.dart'; // Import SplashScreen

final Completer<NavigatorState> navigatorStateCompleter = Completer<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final ValueNotifier<String?> notificationTypeNotifier = ValueNotifier<String?>(null);

// **THE FIX IS HERE:** Add @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to use Firebase services (like Firestore, Auth) in the background handler
  // you MUST call Firebase.initializeApp() here, even if it's called in main().
  // This is because the background handler runs in its own isolated Dart context.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Handling a background message ${message.messageId}');
  print('Message data: ${message.data}'); // Added for better debug
  print('Message notification: ${message.notification?.title}'); // Added for better debug
  
  // You might want to pass message.data to _showLocalNotification if it contains relevant info
  _showLocalNotification(message); // Show local notification in background
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler immediately after Firebase initialization
  // This needs to be done early
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  await _configureLocalNotifications();
  
  // Initialize date formatting
  await initializeDateFormatting('id_ID', null);

  // FCM foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // print('Got a message whilst in the foreground!');
    // print('Message data: ${message.data}');

    if (message.notification != null) {
      // print('Message also contained a notification: ${message.notification}');
      if (message.data['action'] != null && message.data['action'] != '') { // Check for null before checking for empty string
        // print('Notification action: ${message.data['action']}');
        notificationTypeNotifier.value = message.data['action'];
      }
      _showLocalNotification(message); // Show local notification in foreground
    }
  });

  // Request notification permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // print('User granted permission: ${settings.authorizationStatus}');

  // String? token = await messaging.getToken();
  // print('FCM Token: $token');
  // ... save token to backend ...

  runApp(const MyApp()); // runApp should be called once after all setup
}

Future<void> _configureLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

await flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
  print('LOCAL NOTIFICATION TAPPED - Payload: ${notificationResponse.payload}');
  if (notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    try {
      // 1. Di sini, 'data' adalah String? karena notificationResponse.payload adalah String?
      final data = notificationResponse.payload; 

      print("⏳ Waiting for navigator (onDidReceiveNotificationResponse)...");
      try {
        final NavigatorState navigator = await navigatorStateCompleter.future.timeout(
            const Duration(seconds: 5), // Prevent indefinite wait
            onTimeout: () {
              print("⌛️ TIMEOUT waiting for navigator (onDidReceiveNotificationResponse).");
              throw TimeoutException("Navigator not ready in time");
            }
          );
        print("✅ Navigator ready. Navigating (onDidReceiveNotificationResponse).");
        // 2. Anda memanggil _handleNotificationTap dengan 'data' yang merupakan String?
        await _handleNotificationTap(navigator, data); 
      } catch (e) { 
        // 3. Error terjadi di sini, kemungkinan besar DARI DALAM _handleNotificationTap
        //    karena _handleNotificationTap mengharapkan Map<String, dynamic> tetapi menerima String?
        print("🔴 Error obtaining/using navigator from completer (local tap): $e"); 
      }
    } catch (e) { 
      // Catch ini mungkin untuk error lain, bukan yang utama di sini jika tidak ada jsonDecode
      print('🔴 Error (outer try-catch, possibly unrelated to decode if none happened): $e');
    }
  }
},
);

}

Future<void> _showLocalNotification(RemoteMessage message) async {
  try {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Make sure this channel ID is unique and defined
      'your_channel_name', // Make sure this channel name is user-friendly
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('notif'), // Path relatif ke folder android/app/src/main/res/raw
      // Other options like largeIcon, smallIcon can be added here
    );

    // const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    //   presentSound: true,
    //   sound: 'notif.caf', // Nama file suara di proyek Xcode (harus .caf)
    // );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? 'Default Title',
      message.notification?.body ?? 'Default Body',
      platformChannelSpecifics,
      payload: message.notification?.body, // Payload can be used when notification is tapped
    );
  } catch (e) {
    print('Error showing local notification: $e');
  }
}

// main.dart atau di file terpisah (misal, notification_handler.dart)
// Pastikan AppRoutes.navigatorKey sudah diinisialisasi dan di-assign ke MaterialApp

// void _handleNotificationTap(Map<String, dynamic> data) // Old signature
Future<void> _handleNotificationTap(NavigatorState navigator, var data) async { // New signature
  print("📲 Handling tapped notification with navigator, data: $data");

  final String? notificationBody = data;
  // final String? type = data['type'] as String?; // Extracted from FCM message.data
  // String? itemId; // Extracted from data['additionalData'] or data['id']

  // // --- Your logic to extract itemId from 'data' based on 'type' or other fields ---
  // final dynamic additionalData = data['additionalData'];
  // if (additionalData is Map<String, dynamic>) {
  //   if (type == 'leave_request' || data['action'] == 'leave_request_detail') { // From your _submitLeave
  //     itemId = additionalData['izin_id_from_response'] as String?;
  //   } else if (type == 'payslip_ready') {
  //     itemId = additionalData['payslip_id'] as String?;
  //   } // ... Add other types ...
  //   itemId ??= additionalData['id'] as String?; // Generic ID
  // }
  // itemId ??= data['id'] as String?; // Fallback to root ID
  // // --- End of itemId extraction ---

  // Navigation logic using the passed 'navigator'
  if (notificationBody != null) {
    if (notificationBody.contains("New leave")) {
      print("Navigating to Leave Approval (body only)");
      navigator.pushNamed(AppRoutes.leaveApproval); // Tidak bisa kirim leaveId
    } else if (notificationBody.contains('leave request')) { // 'Your leave request'
      print("Navigating to Leave (user's) (body only)");
      navigator.pushNamed(AppRoutes.leave); // Tidak bisa kirim leaveId
    } else if (notificationBody.contains('New Time Off')) {
      print("Navigating to Time Off Approval (body only)");
      navigator.pushNamed(AppRoutes.timeOffApproval); // Tidak bisa kirim timeOffId
    } else if (notificationBody.contains('Time Off request')) { // 'Your Time Off request'
      print("Navigating to Time Off (user's) (body only)");
      navigator.pushNamed(AppRoutes.timeOff); // Tidak bisa kirim timeOffId
    } else if (notificationBody.contains('New overtime')) {
      print("Navigating to Overtime Approval (body only)");
      navigator.pushNamed(AppRoutes.overtimeApproval); // Tidak bisa kirim overtimeId
    } else if (notificationBody.contains('overtime request')) { // 'Your overtime request'
      print("Navigating to Overtime (user's) (body only)");
      navigator.pushNamed(AppRoutes.overtime); // Tidak bisa kirim overtimeId
    } else if (notificationBody.contains('Gaji')) {
      print("Navigating to Payslip (body only)");
      navigator.pushNamed(AppRoutes.payslip); // Tidak bisa kirim payslipId
    } else {
      print("Notification body ('$notificationBody') did not match. Navigating to home.");
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  } else {
    print("Notification body is null. Navigating to home as default.");
    navigator.pushReplacementNamed(AppRoutes.home);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.primary,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return OverlaySupport.global(
      child: MaterialApp(
        navigatorKey: AppRoutes.navigatorKey, 
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(), // Set SplashScreen as the initial home
        routes: AppRoutes.routes,
      ),
    );
  }
}