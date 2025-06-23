import 'package:flutter/material.dart';
import 'package:richzspot/feautures/profile/service/profile_service.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;

  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // State untuk checklist password requirements
  bool _hasMinLength = false;
  bool _hasUppercaseLowercase = false;
  bool _hasNumbers = false;
  bool _hasSpecialCharacters = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePasswordRequirements);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.removeListener(_validatePasswordRequirements);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswordRequirements() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 6;
      // _hasUppercaseLowercase = password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      // _hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ProfileService.changePassword(
          userId: widget.userId,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (response['status'] == 'success') {
          if (mounted) {
            ShowMessage.successNotification("${response['message']}", context);
            Navigator.pop(context); // Kembali ke ProfileScreen
          }
        } else {
          if (mounted) {
            ShowMessage.errorNotification("Failed to change password! ${response['message']}", context);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('')),
            // );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih sesuai gambar
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Ubah ke start untuk judul
                  children: [
                    const SizedBox(height: 50), // Padding atas untuk judul
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Ubah ke start untuk tombol kembali
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black), // Icon panah ke kiri
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10), // Spasi antara ikon dan teks
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30), // Spasi setelah judul

                    // Current Password
                    _buildCustomPasswordFormField(
                      controller: _currentPasswordController,
                      labelText: 'Current Password',
                      hintText: 'Enter current password',
                      obscureText: _obscureCurrentPassword,
                      onTapSuffix: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // New Password
                    _buildCustomPasswordFormField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      obscureText: _obscureNewPassword,
                      onTapSuffix: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        // Validasi dilakukan oleh _validatePasswordRequirements
                        if (!_hasMinLength || !_hasNumbers) {
                          return 'Please meet all password requirements';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm New Password
                    _buildCustomPasswordFormField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm New Password',
                      hintText: 'Confirm new password',
                      obscureText: _obscureConfirmPassword,
                      onTapSuffix: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Password Requirements Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB), // Background abu-abu muda
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password Requirements',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRequirementItem('Minimum 6 characters', _hasMinLength),
                          // _buildRequirementItem('Include uppercase & lowercase', _hasUppercaseLowercase),
                          _buildRequirementItem('Include numbers', _hasNumbers),
                          // _buildRequirementItem('Include special characters', _hasSpecialCharacters),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Update Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6356E5), // Warna ungu dari gambar
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Password',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Memberikan sedikit ruang di bawah
                  ],
                ),
              ),
            ),
    );
  }

  // Widget pembantu untuk TextFormField password kustom
  Widget _buildCustomPasswordFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool obscureText,
    required VoidCallback onTapSuffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280), // Warna abu-abu dari gambar
          ),
        ),
        const SizedBox(height: 4), // Sedikit spasi antara label dan input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Background abu-abu muda di dalam field
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // Warna hint text
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none, // Hapus border
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility, // Ikon mata tertutup/terbuka
                  color: const Color(0xFF9CA3AF), // Warna abu-abu untuk ikon mata
                ),
                onPressed: onTapSuffix,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  // Widget pembantu untuk item persyaratan password
  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked, // Ikon checklist/radio button
            color: isMet ? Colors.green : const Color(0xFF9CA3AF), // Warna hijau jika terpenuhi
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isMet ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF), // Warna teks sesuai status
            ),
          ),
        ],
      ),
    );
  }
}