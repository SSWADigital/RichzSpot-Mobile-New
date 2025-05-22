import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/constant/app_colors.dart' show AppColors;
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/leave/service/leave_service.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:richzspot/feautures/time_off/service/timeoff_service.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import 'package:intl/intl.dart';


class TimeOffApplicationForm extends StatefulWidget {

  final Future<void> Function() onCall;


  const TimeOffApplicationForm({
    Key? key,
    required this.onCall
  }) : super(key: key);

  @override
  _TimeOffApplicationFormState createState() => _TimeOffApplicationFormState();
}

class _TimeOffApplicationFormState extends State<TimeOffApplicationForm> {

final _formKey = GlobalKey<FormState>();
final _startDateController = TextEditingController();
final _endDateController = TextEditingController();
final _reasonController = TextEditingController();

String? _selectedLeaveType;
File? _selectedFile;
bool _isSubmitting = false;
List<Map<String, dynamic>> _timeOffTypes = [];
String? _selectedLeaveTypeId;
String? _selectedLeaveTypeName;
DateTime? _startDate;
DateTime? _endDate;


@override
void initState() {
  super.initState();
  _fetchtimeOffTypes();
}

// Future<void> _sendTestNotification() async {
//     try {
//       // FCM SERVER KEY yang dibuat di Firebase Console
//       const String serverKey = 'YOUR_SERVER_KEY_HERE';
      
//       // Token perangkat tujuan (idealnya dari database)
//       const String deviceToken = 'DEVICE_TOKEN_HERE';
      
//       await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'key=$serverKey',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{
//               'title': 'Notifikasi Test',
//               'body': 'Ini adalah notifikasi test dari RichzSpot',
//             },
//             'priority': 'high',
//             'data': <String, dynamic>{
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'route': '/notifications',
//             },
//             'to': deviceToken,
//           },
//         ),
//       );
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }

Future<void> _fetchtimeOffTypes() async {
  try {
    final data = await TimeOffService.getTimeOffTypes(); // sesuaikan class-nya
    setState(() {
      _timeOffTypes = data;
    });
  } catch (e) {
    // handle error (show snackbar, etc)
  }
}

Future<void> _pickFile() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked != null) {
    setState(() {
      _selectedFile = File(picked.path);
    });
  }
}

Future<void> _submitLeave() async {
  setState(() => _isSubmitting = true);
  final token = await AppStorage.getToken();
  final userId = await AppStorage.getUser();

  final uri = Uri.parse('${App.apiBaseUrl}cuti/addData');
  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..fields['id_user'] = '${userId?['user_id']}'
    ..fields['cuti_tgl_mulai'] = _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : ''
    ..fields['cuti_tgl_selesai'] = _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : ''
    ..fields['id_jenis_cuti'] = _selectedLeaveTypeId ?? ''
    ..fields['cuti_keterangan'] = _reasonController.text
    ..fields['cuti_status'] = 'n'
    ..fields['cuti_created'] = DateTime.now().toIso8601String()
    ..fields['cuti_updated'] = DateTime.now().toIso8601String()
    ..fields['id_dep'] = '${userId?['departemen_id']}' // Sesuaikan
    ..fields['id_hrd'] = 'd2ddb494c9f8184f7eabb836811c442b039f843a'; // Sesuaikan

  if (_selectedFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'bukti_cuti',
        _selectedFile!.path,
      ),
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  final notificationService = NotificationService();
  // final user = await AppStorage.getUser();
  // final deviceToken = await AppStorage.getFCMDeviceToken();
  // print('Response Body Send: ${jsonEncode(response)}');

  if (response.statusCode == 200) {
  // print('Response Body Send: ${response.message}');
    // Kirim notifikasi ke HRD
    // await notificationService.sendFcmNotification(
    //   recipientToken: deviceToken ?? '',
    //   userId: userId?['user_id'],
    //   title: 'Leave Request',
    //   body: 'New leave Request! from ${user?['user_nama_lengkap']}.',
    //   type: 'leave_request',
    //   action: 'leave_request',
    //   menu: 'leave_request',
    //   additionalData: {
    //     'cuti_id': response.body,
    //     'cuti_status': 'n',
    //     'cuti_created': DateTime.now().toIso8601String(),
    //     'cuti_updated': DateTime.now().toIso8601String(),
    //   },
    // );

    
    notificationService.sendFcmNotificationV1(
      // recipientToken: deviceToken ?? '',
      userId: userId?['user_id'],
      title: 'Time Off Request',
      body: 'New Time Off Request! from ${userId?['user_nama_lengkap']}.',
      type: 'timeoff_request',
      action: 'timeoff_request',
      menu: 'timeoff_request',
      additionalData: {
        'cuti_id': response.body,
        'cuti_status': 'n',
        'cuti_created': DateTime.now().toIso8601String(),
        'cuti_updated': DateTime.now().toIso8601String(),
      },
    );

    // print('Sukses: ${response.body}');
    ShowMessage.successNotification("Request sended successfully!", context);
    // setState(() {
      widget.onCall();
    // });
  } else {
    ShowMessage.errorNotification("Failed!", context);
    // print('Gagal: ${response.body}');
  }

  setState(() => _isSubmitting = false);
}


  @override
  Widget build(BuildContext context) {
    return 
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apply for TimeOff',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
  children: [
    Expanded(
      child: _buildDateField('Start Date', _startDate, _selectStartDate),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildDateField('End Date', _endDate, _selectEndDate),
    ),
  ],
),

            const SizedBox(height: 16),
            _buildLeaveTypeField(),
            const SizedBox(height: 16),
            _buildReasonField(),
            const SizedBox(height: 16),
            _buildFileUploadField(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, VoidCallback onTap) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
        ),
      ),
      const SizedBox(height: 9),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                    : 'Select date',
                style: TextStyle(
                  fontSize: 14,
                  color: selectedDate != null
                      ? Colors.black
                      : const Color(0xFF9CA3AF),
                ),
              ),
              const Icon(
                size: 14,
                Icons.calendar_month,
                color: Color(0xFF9CA3AF),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildLeaveTypeField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Leave Type',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLeaveTypeId,
            isExpanded: true,
            hint: const Text('Select Leave type'),
            icon: const Icon(Icons.keyboard_arrow_down),
            dropdownColor: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            items: _timeOffTypes.map((item) {
              return DropdownMenuItem<String>(
                value: item['jenis_cuti_id'],
                child: Text(item['jenis_cuti_nama']),
                
              );
            }).toList(),
            onChanged: (value) {
              final selectedItem = _timeOffTypes.firstWhere((e) => e['jenis_cuti_id'] == value);
              setState(() {
                _selectedLeaveTypeId = value;
                _selectedLeaveTypeName = selectedItem['jenis_cuti_nama'];
              });
            },
          ),
        ),
      ),
    ],
  );
}

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _reasonController, // Hubungkan controller
            maxLines: 5, // Atur tinggi field
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
            decoration: InputDecoration(
              hintText: 'Enter reason for leave',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildFileUploadField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Upload Bukti cuti (optional)',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickFile,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: _selectedFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedFile!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload_outlined, size: 30, color: Color(0xFF9CA3AF)),
                      SizedBox(height: 8),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ],
  );
}


Widget _buildSubmitButton() {
  return GestureDetector(
    onTap: _isSubmitting ? null : _submitLeave,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        color: _isSubmitting ? Colors.grey : const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Submit Request',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Future<void> _selectStartDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _startDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    // barrierColor: AppColors.primary.withOpacity(0.5),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: AppColors.primary,
          // accentColor: AppColors.primary,
          colorScheme: ColorScheme.light(primary: AppColors.primary),
          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    setState(() {
      _startDate = picked;
    });
  }
}

Future<void> _selectEndDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _endDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: AppColors.primary,
          // accentColor: AppColors.primary,
          colorScheme: ColorScheme.light(primary: AppColors.primary),
          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    setState(() {
      _endDate = picked;
    });
  }
}
}
