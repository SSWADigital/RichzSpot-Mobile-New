import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/leave/screen/leave_detail_screen.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:richzspot/shared/widgets/back_icon.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import 'package:richzspot/main.dart';

class TimeOffApprovalScreen extends StatefulWidget {
  const TimeOffApprovalScreen({Key? key}) : super(key: key);

  @override
  State<TimeOffApprovalScreen> createState() => _TimeOffApprovalScreenState();
}

class _TimeOffApprovalScreenState extends State<TimeOffApprovalScreen> {
  int _selectedTabIndex = 0;
  List<dynamic> _timeOffRequest = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final String _baseUrl = App.apiBaseUrl;
  final notificationService = NotificationService();
  // final notificationTypeNotifier = ValueNotifier<String>('timeoff_request');
  // final ValueNotifier<String> notificationTypeNotifier = ValueNotifier<String>('');


  @override
  void initState() {
    super.initState();
    _fetchtimeOffRequest('n');
     notificationTypeNotifier.addListener(_handleNotificationRefresh);

}
  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // If you used a ValueNotifier, dispose it if it's managed here
    notificationTypeNotifier.removeListener(_handleNotificationRefresh);
    super.dispose();
  }

 void _handleNotificationRefresh() {
    if (notificationTypeNotifier.value == 'timeoff_request') {
      _fetchtimeOffRequest('n');
      notificationTypeNotifier.value = ''; // Reset the notifier
    }
  }

  Future<void> _fetchtimeOffRequest(String status) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _timeOffRequest.clear();
    });

    final prefs = await AppStorage.getUser();
    final user = prefs?['departemen_id'];

    final String apiUrl = '${_baseUrl}cuti/getApprovalCuti/$user';


    try {
      final response = await http.get(Uri.parse(apiUrl));

      print('Response Body: ${user}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _timeOffRequest = data.where((item) => item['cuti_status'] == status).toList();
          _isLoading = false;
        });
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = '${errorData['message']}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'There was a connection error: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _processtimeOffRequest(
    String cutiId,
    String recipientUserId,
    String keterangan,
    String action,
  ) async {
    final String apiUrl = '${_baseUrl}cuti/${action}cuti';
    final prefs = await AppStorage.getUser();
    final userId = prefs?['user_id']; // Replace with actual user ID
    final userName = prefs?['user_nama_lengkap']; // Replace with actual user name
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'cuti_id': cutiId,
          'user_id': userId,
          'keterangan': keterangan,
        }),
      );

      final responseData = jsonDecode(response.body);

      print('Response Body timeOff: ${response.body}');

      if (responseData['status'] == 'success') {

        notificationService.sendFcmNotificationV1(
          recipientUserId: recipientUserId,
          userId: userId,
          title: 'timeOff Request ${action == 'approve' ? 'Approved' : 'Rejected'}',
          body: '$userName Time Off request has been ${action == 'approve' ? 'approved' : 'rejected'}.',
          type: 'timeOff_approve',
          action: action,
          menu: 'timeOff_approve',
        );
        // return;  
        ShowMessage.successNotification("cuti berhasil di${action == 'approve' ? 'setujui' : 'tolak'}", context);
        _fetchtimeOffRequest(_selectedTabIndex == 0 ? 'n' : _selectedTabIndex == 1 ? 'y' : 'r'); // Refresh list
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text()),
        // );
        ShowMessage.errorNotification('cuti gagal di${action == 'approve' ? 'setujui' : 'tolak'}', context);
      }
    } catch (error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text()),
      // );
      ShowMessage.errorNotification('Terjadi kesalahan: $error', context);
    }
  }

  Future<void> _showApproveRejectDialog(
  BuildContext context,
  String cutiId,
  String userId,
  String action,
) async {
  TextEditingController keteranganController = TextEditingController();
  const Color accentColor = AppColors.primary; // Define your accent color

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Set background color to white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          action == 'approve' ? 'Setujui cuti?' : 'Tolak cuti?',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: accentColor, // Use accent color for title
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Masukkan keterangan (opsional):',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: keteranganController,
                maxLines: 3,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: accentColor), // Use accent color for focused border
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action == 'approve' ? accentColor : Colors.redAccent, // Use accent color for approve
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2.0,
                    ),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _processtimeOffRequest(cutiId, userId,keteranganController.text.trim(), action);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    String pendingCount = _timeOffRequest.where((item) => item['cuti_status'] == 'n').length.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackIcon(context: context),
                Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'timeOff Approval',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$pendingCount pending requests',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
            
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabButton('Pending', 0),
                    _buildTabButton('Approved', 1),
                    _buildTabButton('Rejected', 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : _timeOffRequest.isEmpty
                            ? const Center(child: Text('No leave requests found for this status.'))
                            : ListView.builder(
                                itemCount: _timeOffRequest.length,
                                itemBuilder: (context, index) {
                                  final leave = _timeOffRequest[index];
                                  return LeaveRequestCard(
                                    leaveData: leave,
                                    onClick: () {
                                      // Handle click on the card
                                      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaveDetailScreen(
              leaveData: leave,
              onApprove: () {
                // if (onApprove != null) {
                  _showApproveRejectDialog(context, leave['cuti_id'], leave['id_user'], 'approve');
                // }
              },
              onReject: () {
                // if (onReject != null) {
                  _showApproveRejectDialog(context, leave['cuti_id'], leave['id_user'],'reject');
                // }
              },
            ),
          ),
        );
                                    },
                                    onApprove: () {
                                      _showApproveRejectDialog(context, leave['cuti_id'], leave['id_user'],'approve');
                                    },
                                    onReject: () {
                                      _showApproveRejectDialog(context, leave['cuti_id'], leave['id_user'],'reject');
                                    },
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTabIndex = index);
          String status = '';
          switch (index) {
            case 0:
              status = 'n';
              break;
            case 1:
              status = 'y';
              break;
            case 2:
              status = 'x';
              break;
          }
          _fetchtimeOffRequest(status);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ),
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final dynamic leaveData;
  final VoidCallback onClick;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const LeaveRequestCard({
    Key? key,
    required this.leaveData,
    required this.onClick,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = leaveData['user_nama_lengkap'] ?? 'N/A';
    final String leaveType = leaveData['jenis_cuti_nama'] ?? 'N/A';
    final String dateInfo = '${leaveData['cuti_tgl_mulai']} - ${leaveData['cuti_tgl_selesai']}';
    final String additionalInfo = leaveData['cuti_keterangan'] ?? '-';
    final String status = leaveData['cuti_status'];
    final String date = leaveData['cuti_created'] ?? 'N/A';

    return GestureDetector(
      onTap: onClick,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$leaveType - $date',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dateInfo,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (additionalInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Keterangan: $additionalInfo',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (status == 'n')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity, // Make the button full width
                child: ElevatedButton(
                  onPressed: onClick, // Use onClick for detail
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}