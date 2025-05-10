import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/shared/widgets/custom_input.dart';
import 'package:richzspot/shared/widgets/gradient_button.dart';

class SignScreen extends StatelessWidget {
  const SignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
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
                        const CustomInputField(
                          placeholder: 'Enter your email',
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 16),
                        const CustomInputField(
                          placeholder: 'Enter your password',
                          icon: Icons.remove_red_eye_outlined,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Login',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Face Recognition Section
                  Column(
                    children: [
                      Container(
                        width: 59,
                        height: 59,
                        decoration: BoxDecoration(
                          gradient: AppColors.circleGradient,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFBFDBFE),
                              offset: Offset(0, 9.219),
                              blurRadius: 13.828,
                              spreadRadius: -2.766,
                            ),
                            BoxShadow(
                              color: Color(0xFFBFDBFE),
                              offset: Offset(0, 3.688),
                              blurRadius: 5.531,
                              spreadRadius: -3.688,
                            ),
                          ],
                        ),
                        child: Image.network(
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/b4d50370cbabf44eca087740c4cd832eaa16eadd',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        'Login with Face Reco',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
