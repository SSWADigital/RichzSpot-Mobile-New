import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/fcmserverkey.dart';
import 'package:richzspot/feautures/auth/services/auth_service.dart';
import 'package:richzspot/shared/widgets/custom_input.dart';
import 'package:richzspot/shared/widgets/gradient_button.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import 'dart:io';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final authService = AuthService();
  final emailController = TextEditingController();
  bool isLoading = false;
  final passwordController = TextEditingController();

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');
    print('FCM Device Token saat Login: $fcmToken');
    print('Platform saat Login: $platform');

    final getFcmServerKey = GetFcmServerKey();
    getFcmServerKey.serverToken().then((value) async {
    await AppStorage.setFCMServerToken(value!);
    // print('FCM Server Token: $value');
    }).catchError((error) {
      print('Error getting FCM Server Token: $error');
    });

    // Simpan token dan platform ke storage
    await AppStorage.setFCMDeviceToken(fcmToken!);
    await AppStorage.setPlatform(platform);

    final result = await authService.login(
      emailController.text,
      passwordController.text,
      fcmToken, // Kirim FCM token
      platform, // Kirim platform
    );

    setState(() => isLoading = false);

    if (result['status'] == true) {
      final token = result['token'];
      final user = result['data'];
      final refreshToken = result['refresh_token'];


      await AppStorage.saveLoginData(token, refreshToken, user);

      if (user['face_token'] == null || user['face_token'] == '') {
        Navigator.pushReplacementNamed(context, AppRoutes.faceRecognationRegister);
      } else {
        // if (user['role_id'] == '4') {
          // Navigator.pushReplacementNamed(context, AppRoutes.appRootStaff);
        // } else {
          Navigator.pushReplacementNamed(context, AppRoutes.appRoot);
        // }
      }
    } else {
      ShowMessage.errorNotification(result['message'] ?? 'Login failed', context);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        // <<< AWAL PERUBAHAN >>>
        // Bungkus Center dengan SizedBox untuk memberikan tinggi referensi
        child: SizedBox(
          // Ambil tinggi layar dan kurangi padding atas (status bar) agar perhitungan akurat di dalam SafeArea
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
              child: Column(
                // mainAxisAlignment akan memusatkan semua anak Column secara vertikal
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      Text(
                        'RichzSpot',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Future of Attendance',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Login Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x80F3F4F6),
                          offset: Offset(0, 10),
                          blurRadius: 15,
                          spreadRadius: -3,
                        ),
                        BoxShadow(
                          color: Color(0x80F3F4F6),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CustomInputField(
                          placeholder: 'Enter your email',
                          icon: Icons.mail_outline,
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          placeholder: 'Enter your password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: isLoading ? 'Loading...' : 'Login',
                          onPressed: handleLogin, // Nonaktifkan tombol saat loading
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // Face Recognition Section
                  // Column(
                  //   children: [
                  //     Container(
                  //       width: 59,
                  //       height: 59,
                  //       decoration: BoxDecoration(
                  //         gradient: AppColors.circleGradient,
                  //         shape: BoxShape.circle,
                  //         boxShadow: const [
                  //           BoxShadow(
                  //             color: Color(0xFFBFDBFE),
                  //             offset: Offset(0, 9.219),
                  //             blurRadius: 13.828,
                  //             spreadRadius: -2.766,
                  //           ),
                  //           BoxShadow(
                  //             color: Color(0xFFBFDBFE),
                  //             offset: Offset(0, 3.688),
                  //             blurRadius: 5.531,
                  //             spreadRadius: -3.688,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Image.network(
                  //         'https://cdn.builder.io/api/v1/image/assets/TEMP/b4d50370cbabf44eca087740c4cd832eaa16eadd',
                  //         width: 60,
                  //         height: 60,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 13),
                  //     const Text(
                  //       'Login with Face Reco',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: AppColors.textSecondary,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
  }

}
