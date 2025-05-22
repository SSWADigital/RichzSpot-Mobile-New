import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:richzspot/feautures/overtime/service/overtime_service.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import '../widgets/status_badge.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({Key? key}) : super(key: key);

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final _formKey = GlobalKey<FormState>();

final _dateController = TextEditingController();
final _typeController = TextEditingController();
final _hoursStartController = TextEditingController();
final _hoursEndController = TextEditingController();
final _reasonController = TextEditingController();
  int _selectedNavIndex = 0;
  final DateTime _selectedDate = DateTime(2024, 2, 15);
  List<Map<String, dynamic>> overtimeTypes = [];
bool _isLoadingOvertimeTypes = true;
String? _selectedOvertimeTypeId;

Future<void> loadOvertimeRequests() async {
  try {
    final userId = await AppStorage.getUser(); // Buat method ini di AppStorage jika belum ada
    final requests = await OvertimeService.getOvertimeRequestsByUserId(userId?['user_id'] ?? '');

    setState(() {
      _overtimeRequests = requests;
      _isLoadingOvertimeRequests = false;
    });
  } catch (e) {
    print('Error fetching overtime requests: $e');
    setState(() {
      _isLoadingOvertimeRequests = false;
    });
  }
}


List<Map<String, dynamic>> _overtimeRequests = [];
bool _isLoadingOvertimeRequests = true;

Future<void> loadOvertimeTypes() async {
  try {
    final types = await OvertimeService.getOvertimeTypes();
    setState(() {
      overtimeTypes = types;
      _isLoadingOvertimeTypes = false;
    });
  } catch (e) {
    print('Error fetching types: $e');
    setState(() {
      _isLoadingOvertimeTypes = false;
    });
  }
}
@override
  void initState() {
    super.initState();
    loadOvertimeTypes();
    loadOvertimeRequests();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
                  child: _buildNewRequestCard(),  
                ),
                const SizedBox(height: 24),
                _buildCurrentStatusCard(),
                const SizedBox(height: 24),
                _buildPreviousRequests(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return 
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new) 
                    ),
          Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Overtime',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            height: 32/24,
          ),
        ),
        Text(
          'Request & History',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 24/16,
          ),
        ),
      ],
    ),
  
      ],
    );
  
  }

  Widget _buildNewRequestCard() {
  return Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Request',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              height: 28 / 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Select Date',
            child: TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2023),
    lastDate: DateTime(2025, 12, 31), // ✅ ini penting
  );
  if (picked != null) {
    _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
  }
},

              decoration: const InputDecoration.collapsed(hintText: 'Choose date'),
              validator: (value) => value == null || value.isEmpty ? 'Please select date' : null,
            ),
          ),
          _buildFormField(
  label: 'Overtime Type',
  child: _isLoadingOvertimeTypes
      ? const Center(child: Text("Loading..."))
      : DropdownButtonFormField<String>(
          value: _selectedOvertimeTypeId,
          decoration: const InputDecoration.collapsed(hintText: ''),
          items: overtimeTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type['jenis_lembur_id'],
              child: Text(type['jenis_lembur_nama']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOvertimeTypeId = value;
              _typeController.text = value ?? '';
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select type' : null,
        ),

),
          _buildFormField(
  label: 'Hours Start',
  child: TextFormField(
    controller: _hoursStartController,
    readOnly: true,
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final formattedTime = _formatTimeOfDay(picked);
        _hoursStartController.text = formattedTime;
      }
    },
    decoration: const InputDecoration.collapsed(hintText: 'Select start time'),
    validator: (value) => value == null || value.isEmpty ? 'Please enter start time' : null,
  ),
),

          _buildFormField(
  label: 'Hours End',
  child: TextFormField(
    controller: _hoursEndController,
    readOnly: true,
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final formattedTime = _formatTimeOfDay(picked);
        _hoursEndController.text = formattedTime;
      }
    },
    decoration: const InputDecoration.collapsed(hintText: 'Select end time'),
    validator: (value) => value == null || value.isEmpty ? 'Please enter end time' : null,
  ),
),
          _buildFormField(
            label: 'Reason',
            isLast: true,
            child: TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration.collapsed(hintText: 'Enter reason'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter reason' : null,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildFormField({
    required String label,
    required Widget child,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              height: 20/14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
  if (_isLoadingOvertimeRequests) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_overtimeRequests.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('Belum ada permintaan lembur.'),
    );
  }

  final latestRequest = _overtimeRequests.first;
  final status = _parseStatus(latestRequest['lembur_status']);

  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Request Status',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            height: 24 / 16,
          ),
        ),
        const SizedBox(height: 12),
        StatusBadge(status: status),
      ],
    ),
  );
}

  Widget _buildPreviousRequests() {
  if (_isLoadingOvertimeRequests) {
    return const CircularProgressIndicator(
      color: AppColors.primary,
      // strokeWidth: 2,
    ); // loading spinner
  }

  final previousRequests = _overtimeRequests.skip(1).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Previous Requests',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          height: 28 / 18,
        ),
      ),
      const SizedBox(height: 16),
      ...previousRequests.map((item) {
        final date = DateTime.parse(item['lembur_tgl']);
        final hours = item['lembur_jam_mulai'] + ' - ' + item['lembur_jam_selesai'];
        final status = _parseStatus(item['lembur_status']);

        return Column(
          children: [
            _buildRequestItem(
              date: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              hours: hours,
              status: status,
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    ],
  );
}

  Widget _buildRequestItem({
    required String date,
    required String hours,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 16,
                  height: 24/16,
                ),
              ),
              Text(
                hours,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 20/14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              StatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {

      final userId = await AppStorage.getUser(); // Ambil user ID dari storage
      final notificationService = NotificationService();
      
      final response = await OvertimeService.submitOvertimeRequest(
        date: _dateController.text,
        type: _selectedOvertimeTypeId,
        hoursStart: _hoursStartController.text,
        hoursEnd: _hoursEndController.text,
        reason: _reasonController.text,
      );


      if (response.statusCode == 200) {
        ShowMessage.successNotification('Success! Request submitted successfully', context);
        // Opsional: Kosongkan form setelah berhasil
        _formKey.currentState!.reset();
        _dateController.clear();
        _typeController.clear();
        _hoursStartController.clear();
        _hoursEndController.clear();
        _reasonController.clear();
        // _selectedOvertimeTypeId = '';

        // Reload the overtime requests to show the new request
        notificationService.sendFcmNotificationV1(
      // recipientToken: deviceToken ?? '',
      userId: userId?['user_id'],
      title: 'Overtime Request',
      body: 'New overtime Request! from ${userId?['user_nama_lengkap']}.',
      type: 'overtime_request',
      action: 'overtime_request',
      menu: 'overtime_request',
      additionalData: {
        'overtime_id': response.body,
        'overtime_status': 'n',
        'overtime_created': DateTime.now().toIso8601String(),
        'overtime_updated': DateTime.now().toIso8601String(),
      },
    );
        loadOvertimeRequests();

      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Request failed';
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: $errorMsg')),
        // );
        ShowMessage.errorNotification('Error: ${response.body}', context);
      }
    } catch (e) {
      ShowMessage.errorNotification('Error: $e', context);
    }
  }
}

String _formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
}

String _parseStatus(String? statusCode) {
  switch (statusCode) {
    case 's':
      return 'Approved';
    case 'r':
      return 'Rejected';
    case 'n':
    default:
      return 'Pending Approval';
  }
}



}
