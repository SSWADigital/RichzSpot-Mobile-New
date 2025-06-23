// lib/feautures/profile/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/profile/service/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:richzspot/shared/widgets/show_messages.dart'; // Import for date formatting

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _employeeIdController;
  late TextEditingController _departmentController;
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _birthDateController; // New controller for birth date

  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData['user_nama_lengkap'] ?? '');
    _phoneNumberController = TextEditingController(text: widget.userData['user_no_telp'] ?? '');
    _addressController = TextEditingController(text: widget.userData['user_alamat'] ?? '');
    _emailController = TextEditingController(text: widget.userData['alamat_email'] ?? widget.userData['alamat_email'] ?? '');
    _employeeIdController = TextEditingController(text: widget.userData['kode_pegawai'] ?? '-');
    _departmentController = TextEditingController(text: widget.userData['departemen_nama'] ?? '-');
    _jobTitleController = TextEditingController(text: widget.userData['role_nama'] ?? '-');
    _companyController = TextEditingController(text: widget.userData['departemen_nama'] ?? '-');

    // Initialize _birthDateController
    // Check if user_tgl_lahir exists and is not null/empty, then format it
    String? rawDate = widget.userData['user_tgl_lahir'];
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        _birthDateController = TextEditingController(text: DateFormat('dd MMMM yyyy').format(parsedDate));
      } catch (e) {
        _birthDateController = TextEditingController(text: ''); // Fallback if parsing fails
      }
    } else {
      _birthDateController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _birthDateController.dispose(); // Dispose new controller
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
https://www.google.com/search?q=youtubr&oq=youtubr&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIPCAEQLhgKGIMBGLEDGIAEMg8IAhAAGAoYgwEYsQMYgAQyDwgDEAAYChiDARixAxiABDIPCAQQABgKGIMBGLEDGIAEMgwIBRAAGAoYsQMYgAQyCQgGEAAYChiABDIGCAcQBRhA0gEHODA2ajBqNKgCALACAQ&sourceid=chrome&ie=UTF-8
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF007AFF), // Header background color
            colorScheme: const ColorScheme.light(primary: Color(0xFF007AFF)), // Selected date color
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newUserData = {
        'user_id': widget.userData['user_id'],
        'user_nama_lengkap': _fullNameController.text,
        'user_no_telp': _phoneNumberController.text,
        'user_alamat': _addressController.text,
        'alamat_email': _emailController.text,
        'user_tgl_lahir': _birthDateController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(DateFormat('dd MMMM yyyy').parse(_birthDateController.text))
            : '', // Format to YYYY-MM-DD for API
      };

      try {
        final response = await ProfileService.updateProfile(newUserData, _pickedImage);

        if (response['status'] == 'success') {
          // Update local storage with potentially new data, including birth date
          await AppStorage.saveUser(response['data']);
          if (mounted) {
            ShowMessage.successNotification("Profile updated successfully!", context);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Profile updated successfully!')),
            // );
            Navigator.pop(context, response['data']);
          }
        } else {
          if (mounted) {
            ShowMessage.errorNotification("Failed to update profile! ${response['message']}", context);
          }
        }
      } catch (e) {
        if (mounted) {
          ShowMessage.errorNotification("An error occurred: $e", context);
          
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: _updateProfile,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Color(0xFF007AFF), fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: _pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    widget.userData['user_foto'] ?? 'https://via.placeholder.com/100',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person, size: 100, color: Colors.grey);
                                    },
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _pickImage,
                        child: const Text(
                          'Change Photo',
                          style: TextStyle(color: Color(0xFF007AFF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildCustomTextFormField(
                      controller: _fullNameController,
                      labelText: 'Full Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    _buildCustomTextFormField(
                      controller: _jobTitleController,
                      labelText: 'Job Title',
                      readOnly: true,
                    ),
                    _buildCustomTextFormField(
                      controller: _companyController,
                      labelText: 'Company',
                      readOnly: true,
                    ),
                    _buildCustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    _buildCustomTextFormField(
                      controller: _addressController,
                      labelText: 'Address',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    _buildCustomTextFormField(
                      controller: _phoneNumberController,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    _buildCustomTextFormField(
                      controller: _employeeIdController,
                      labelText: 'Employee ID',
                      readOnly: true,
                    ),
                    _buildCustomTextFormField(
                      controller: _departmentController,
                      labelText: 'Department',
                      readOnly: true,
                    ),
                    // New field for Birth Date
                    _buildCustomTextFormField(
                      controller: _birthDateController,
                      labelText: 'Date of Birth',
                      readOnly: true, // Make it read-only as it's picked from a date picker
                      onTap: () => _selectDate(context), // Open date picker on tap
                      suffixIcon: Icons.calendar_today, // Calendar icon
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget pembantu untuk TextFormField kustom tanpa border
  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
    int maxLines = 1,
    VoidCallback? onTap, // New parameter for onTap
    IconData? suffixIcon, // New parameter for suffix icon
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            validator: validator,
            maxLines: maxLines,
            onTap: onTap, // Assign onTap
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              isDense: true,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: const Color(0xFF9CA3AF), // Warna abu-abu untuk ikon
                      size: 20,
                    )
                  : null,
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}