import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/profile/change_password_screen.dart';
import 'package:richzspot/feautures/profile/edit_profile_screen.dart';
import 'package:richzspot/feautures/profile/widgets/info_item.dart';
import 'package:richzspot/feautures/profile/widgets/setting_item.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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

  Future<bool> callLogoutApi(String token) async {
  
  // final token = AppStorage.getToken(); // Ambil token dari storage
  // if (token == null || token.toString().isEmpty) {
  //   // print('No token found, cannot logout');
  //   return false; // Tidak ada token, tidak bisa logout
  // }

  final url = Uri.parse('${App.apiBaseUrl}Auth/logout'); // Ganti dengan URL API logout Anda yang sebenarnya
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Logout API success!');
      return true;
    } else {
      print('Logout API failed: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error calling logout API: $e');
    return false;
  }
}
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(color: AppColors.textDark),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary), // Warna teks tombol Cancel
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Warna teks Logout tetap merah
            ),
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              final token = await AppStorage.getToken(); 

              if (token != null) {
                final success = await callLogoutApi(token);

                Navigator.of(context).pop(); // Tutup indikator loading

                if (success) {
                  await AppStorage.clear();
                  Navigator.pushReplacementNamed(context, AppRoutes.sign);
                } else {
                  await AppStorage.clear();
                  Navigator.pushReplacementNamed(context, AppRoutes.sign);
                  // Anda bisa menambahkan notifikasi di sini, misalnya:
                  // showSimpleNotification(
                  //   const Text('Failed to log out from server.'),
                  //   background: Colors.red,
                  // );
                }
              } else {
                Navigator.of(context).pop(); // Tutup indikator loading
                await AppStorage.clear();
                Navigator.pushReplacementNamed(context, AppRoutes.sign);
                print('No token found for logout.');
              }
            },
          ),
        ],
      );
    },
  );
}

  // Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == '-') {
      return '-';
    }
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.network(
                          '${userData['user_foto']}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 80, color: Colors.grey); // Placeholder jika gambar error/null
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 7,
                        ),
                        child: Text(
                          '${userData['user_nama_lengkap']}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF111827),
                            height: 1.4,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 4,
                        ),
                        child: Text(
                          '${userData['role_nama'] ?? 'Role'} • ${userData['departemen_nama'] ?? 'Departemen'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Account Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Account Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InfoItem(
                          icon: 'assets/profile/1.png',
                          label: 'Email',
                          value: '${userData['alamat_email'] ?? '-'}', // Prefer user_email
                        ),
                        InfoItem(
                          icon: 'assets/profile/2.png',
                          label: 'Phone Number',
                          value: '${userData['user_no_telp'] ?? '-'}',
                        ),
                        InfoItem(
                          icon: 'assets/profile/3.png',
                          label: 'Employee ID',
                          value: '${userData['kode_pegawai'] ?? '-'}',
                        ),
                        InfoItem(
                          icon: 'assets/profile/4.png',
                          label: 'Department',
                          value: '${userData['departemen_nama'] ?? '-'}',
                        ),
                        // NEW: InfoItem for Address
                        InfoItem(
                          icon: 'assets/profile/4.png', // You'll need an icon for address
                          label: 'Address',
                          value: '${userData['user_alamat'] ?? '-'}',
                        ),
                        // NEW: InfoItem for Date of Birth
                        InfoItem(
                          icon: 'assets/profile/5.png', // You'll need an icon for birth date
                          label: 'Date of Birth',
                          value: _formatDate(userData['user_tgl_lahir']),
                        ),
                        InfoItem(
                          icon: 'assets/profile/5.png',
                          label: 'Join Date',
                          value: _formatDate(userData['user_tgl_awal_kerja']), // Use _formatDate for join date too
                        ),
                        const SizedBox(height: 10),
                        // Tombol Edit Account Info
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(userData: userData),
                                ),
                              );
                              if (updatedData != null) {
                                setState(() {
                                  userData = updatedData;
                                });
                                AppStorage.saveUser(updatedData);
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit Account Info',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Security Settings Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Security Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SettingsItem(
                          icon: 'assets/profile/6.png',
                          label: 'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(userId: userData['user_id']),
                              ),
                            );
                          },
                        ),
                        SettingsItem(
                          icon: 'assets/profile/8.png',
                          label: 'Logout',
                          isDestructive: true,
                          onTap: () {
                            _showLogoutConfirmationDialog(context);
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}