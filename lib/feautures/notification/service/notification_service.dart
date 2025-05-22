import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/notification/model/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Inisialisasi untuk Local Notifications
  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        print('Notification clicked: ${details.payload}');
      },
    );
  }

  // Inisialisasi FCM
  Future<void> initPushNotifications() async {
    // Meminta izin notifikasi dari pengguna
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Dapatkan token FCM untuk perangkat ini
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Simpan token ke database Anda jika perlu
    // saveTokenToDatabase(token);
    
    // Handler untuk pesan yang datang saat aplikasi berjalan di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan diterima di foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handler untuk pesan yang datang saat aplikasi berada di background tapi masih berjalan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Aplikasi dibuka dari notifikasi background: ${message.notification?.title}');
      // Navigasi ke halaman tertentu jika diperlukan
    });
  }

  // Tampilkan notifikasi lokal
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'richzspot_channel',
      'RichzSpot Notifications',
      channelDescription: 'Channel for RichzSpot app notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );
    
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data['route'],
    );
  }

  // Setup background message handler
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    print('Background message received: ${message.notification?.title}');
    // Anda tidak dapat menampilkan UI atau melakukan navigasi di sini
    // Handler ini untuk pemrosesan data di background
  }

Future<bool> sendFcmNotificationV1({
  String? recipientUserId,
  required String userId,
  required String title,
  required String body,
  String? recipientToken,
  String? type, // Tambahkan parameter untuk jenis notifikasi (misalnya, 'pengajuan', 'pengumuman')
  String? action, // Tambahkan parameter untuk tindakan (misalnya, 'approve', 'reject')
  String? menu, // Tambahkan parameter untuk menu terkait (misalnya, 'pengajuan_detail', 'pengumuman_detail')
  Map<String, dynamic>? additionalData, // Tambahkan parameter untuk data tambahan yang spesifik
}) async {
  final authToken = await AppStorage.getToken();
  final user = await AppStorage.getUser();
  final url = Uri.parse('${App.apiBaseUrl}/Notifikasi/send_fcm_notification_v1');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'user_id': userId,
        'recipient_token': recipientToken,
        'recipient_user_id': recipientUserId,
        'title': title,
        'body': body,
        'type': type,
        'action': action,
        'menu': menu,
        'departemen_id': user?['id_departemen'] ?? '',
        'data': additionalData ?? {},
      }),
    );

    print('Response Body Notif: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['status'] == true;
    } else {
      print('Failed to send FCM V1 notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error sending FCM V1 notification: $e');
    return false;
  }
}

  Future<List<NotificationModel>> getNotifications() async {
    final authToken = await AppStorage.getToken();
    final url = Uri.parse('${App.apiBaseUrl}/Notifikasi/get_notifications');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          List<NotificationModel> notifications = (responseData['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList();
          return notifications;
        } else {
          print('Failed to get notifications: ${responseData['message']}');
          return [];
        }
      } else {
        print('Failed to get notifications. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    final authToken = await AppStorage.getToken();
    final url = Uri.parse('${App.apiBaseUrl}/Notifikasi/mark_as_read');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'notification_id': notificationId}),
      );

      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['status'] == true;
      } else {
        print('Failed to mark as read. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    final authToken = await AppStorage.getToken();
    final url = Uri.parse('${App.apiBaseUrl}/Notifikasi/delete_notification');


    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'notification_id': notificationId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['status'] == true;
      } else {
        print('Failed to delete notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

}