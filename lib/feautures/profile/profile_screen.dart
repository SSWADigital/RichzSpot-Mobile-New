import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/profile/change_password_screen.dart';
import 'package:richzspot/feautures/profile/edit_profile_screen.dart';
import 'package:richzspot/feautures/profile/widgets/info_item.dart';
import 'package:richzspot/feautures/profile/widgets/setting_item.dart';


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

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
              onPressed: () {
                AppStorage.clear();
                Navigator.pushReplacementNamed(context, AppRoutes.sign);
              },
            ),
          ],
        );
      },
    );
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
                          textAlign: TextAlign.center, // Tambahkan ini jika nama bisa panjang
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
                          textAlign: TextAlign.center, // Tambahkan ini jika role/departemen bisa panjang
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
                      color: const Color(0xFFF9FAFB), // Warna background yang lebih lembut
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
                              fontWeight: FontWeight.bold, // Tambahkan bold
                              color: Color(0xFF111827),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InfoItem(
                          icon: 'assets/profile/1.png',
                          label: 'Email',
                          value: '${userData['user_username'] ?? '-'}',
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
                        InfoItem(
                          icon: 'assets/profile/5.png',
                          label: 'Join Date',
                          value: '${userData['user_tgl_awal_kerja'] ?? '-'}',
                        ),
                        const SizedBox(height: 10), // Spasi sebelum tombol edit
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
                                AppStorage.saveUser(updatedData); // Update data di storage
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit Account Info',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF), // Biru utama
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
                      color: const Color(0xFFF9FAFB), // Warna background yang lebih lembut
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
                              fontWeight: FontWeight.bold, // Tambahkan bold
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
                            _showLogoutConfirmationDialog(context); // Show confirmation dialog
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