import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/core/constant/app_colors.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.4);
          }),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textGray,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Informasi pengguna
  String email = 'candra.v@swadigital.com';
  String phone = '+62 812 3456 7890';
  String department = 'Engineering';

  bool isEditingEmail = false;
  bool isEditingPhone = false;
  bool isEditingDepartment = false;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _emailError = false;
  bool _phoneError = false;
  bool _departmentError = false;

  bool isFaceLoginEnabled = true;

  // Foto profil
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildProfileAvatar(),
              SizedBox(height: 10),
              _buildProfileHeader(),
              SizedBox(height: 30),
              _buildSectionTitle('Account Info'),
              _buildEditableField(
                'Email',
                email,
                Icons.email,
                isEditingEmail,
                _emailController,
                onEdit: () => setState(() => isEditingEmail = true),
                onSave: () {
                  String val = _emailController.text;
                  bool isValid = RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val);
                  setState(() {
                    if (isValid) {
                      email = val;
                      isEditingEmail = false;
                      _emailError = false;
                    } else {
                      _emailError = true;
                    }
                  });
                },
                onCancel: () => setState(() {
                  isEditingEmail = false;
                  _emailError = false;
                }),
              ),
              _buildEditableField(
                'Phone Number',
                phone,
                Icons.phone,
                isEditingPhone,
                _phoneController,
                onEdit: () => setState(() => isEditingPhone = true),
                onSave: () {
                  String val = _phoneController.text;
                  bool isValid = RegExp(r'^[0-9+ ]{8,}$').hasMatch(val);
                  setState(() {
                    if (isValid) {
                      phone = val;
                      isEditingPhone = false;
                      _phoneError = false;
                    } else {
                      _phoneError = true;
                    }
                  });
                },
                onCancel: () => setState(() {
                  isEditingPhone = false;
                  _phoneError = false;
                }),
              ),
              _buildInfoTile('Employee ID', 'SWA-2023-001', Icons.badge),
              _buildEditableField(
                'Department',
                department,
                Icons.apartment,
                isEditingDepartment,
                _departmentController,
                onEdit: () => setState(() => isEditingDepartment = true),
                onSave: () {
                  String val = _departmentController.text;
                  setState(() {
                    if (val.trim().isNotEmpty) {
                      department = val;
                      isEditingDepartment = false;
                      _departmentError = false;
                    } else {
                      _departmentError = true;
                    }
                  });
                },
                onCancel: () => setState(() {
                  isEditingDepartment = false;
                  _departmentError = false;
                }),
              ),
              _buildInfoTile('Join Date', 'January 15, 2023', Icons.date_range),
              SizedBox(height: 20),
              _buildSectionTitle('Security Settings'),

              // Change Password - rapi dengan trailing chevron_right
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: _iconWithCircle(Icons.lock, AppColors.primary),
                title: Text('Change Password'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate ke halaman ganti password
                },
              ),

              // Enable Face Login - menggunakan ListTile + trailing Switch agar sejajar
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: _iconWithCircle(
                  Icons.face_retouching_natural,
                  isFaceLoginEnabled ? AppColors.primary : Colors.grey,
                ),
                title: Text('Enable Face Login'),
                trailing: Switch(
                  value: isFaceLoginEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      isFaceLoginEnabled = val;
                    });
                  },
                ),
              ),

              SizedBox(height: 10),

              // Logout - rapi dengan warna merah dan icon bulat
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: _iconWithCircle(Icons.logout, Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  // TODO: Logout logic
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : NetworkImage('https://i.pravatar.cc/300') as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: Icon(Icons.edit, color: AppColors.primary, size: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Text(
          'Candra Vradita',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Text(
          'Programmer • PT. SWA Digital',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String title,
    String value,
    IconData icon,
    bool isEditing,
    TextEditingController controller, {
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
    if (isEditing) {
      controller.text = value;

      String? errorText;
      if (title == 'Email' && _emailError) {
        errorText = 'Please enter a valid email address';
      } else if (title == 'Phone Number' && _phoneError) {
        errorText = 'Only digits, spaces, + allowed (min 8 characters)';
      } else if (title == 'Department' && _departmentError) {
        errorText = 'Department cannot be empty';
      }

      TextInputType keyboardType = TextInputType.text;
      if (title == 'Email') keyboardType = TextInputType.emailAddress;
      if (title == 'Phone Number') keyboardType = TextInputType.phone;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _iconWithCircle(icon, AppColors.primary),
            title: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: title,
                errorText: errorText,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: Text('Cancel')),
              SizedBox(width: 8),
              ElevatedButton(onPressed: onSave, child: Text('Save')),
            ],
          )
        ],
      );
    }

    return ListTile(
      leading: _iconWithCircle(icon, AppColors.primary),
      title: Text(title),
      subtitle: Text(value),
      trailing: Icon(Icons.chevron_right),
      onTap: onEdit,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: _iconWithCircle(icon, AppColors.primary),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _iconWithCircle(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      radius: 20,
      child: Icon(icon, color: color, size: 20),
    );
  }
}
