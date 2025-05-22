import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveDetailScreen extends StatelessWidget {
final dynamic leaveData;
final VoidCallback onApprove;
final VoidCallback onReject;

const LeaveDetailScreen({
super.key,
required this.leaveData,
required this.onApprove,
required this.onReject,
});

@override
Widget build(BuildContext context) {
final String profileUrl = leaveData['user_foto'] ?? '';
final String name = leaveData['user_nama_lengkap'] ?? 'N/A';
final String leaveType = leaveData['jenis_izin_nama'] ?? 'N/A';
final String startDate = leaveData['izin_tgl_mulai'] ?? 'N/A';
final String endDate = leaveData['izin_tgl_selesai'] ?? 'N/A';
final String reason = leaveData['izin_keterangan'] ?? '-';
final String status = leaveData['izin_status'] ?? 'n';
final String fileUrl = leaveData['izin_file'] ?? '';

String statusText = '';
Color statusColor = AppColors.pendingBg;
Color statusTextColor = AppColors.pendingText;

switch (status) {
  case 'y':
    statusText = 'Approved';
    statusColor = AppColors.approveBg;
    statusTextColor = AppColors.approveText;
    break;
  case 'r':
  case 'x':
    statusText = 'Rejected';
    statusColor = AppColors.rejectBg;
    statusTextColor = AppColors.rejectText;
    break;
  case 'n':
  default:
    statusText = 'Pending';
    statusColor = AppColors.pendingBg;
    statusTextColor = AppColors.pendingText;
    break;
}

return Scaffold(
  backgroundColor: AppColors.background,
  body: SafeArea(
    child: Column(
      children: [
        // Header
        Container(
          height: 44,
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Leave Request Detail',
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.text,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: profileUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(Icons.account_circle, size: 48, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          leaveType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusTextColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave Request Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.pendingBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFB45309),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Leave Request Details',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.text,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date Section
                    _buildDetailSection(
                      'Date',
                      '$startDate - $endDate',
                    ),
                    const SizedBox(height: 24),

                    // Duration Section
                    _buildDetailSection(
                      'Duration',
                      _calculateDuration(startDate, endDate),
                    ),
                    const SizedBox(height: 24),

                    // Reason Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reason',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reason == '-' ? 'No reason provided.' : reason,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Attachment Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachment',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (fileUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () async {
                              final Uri uri = Uri.parse(fileUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                ShowMessage.errorNotification('Could not launch file.', context);
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.attachmentBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.insert_drive_file_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileUrl.split('/').last,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.text,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      // You might want to display file size if available
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.download_outlined,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text('No attachment provided.'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        if (status == 'n')
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.approveBg,
                      foregroundColor: AppColors.approveText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rejectBg,
                      foregroundColor: AppColors.rejectText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
);
}

Widget _buildDetailSection(String label, String value) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
fontSize: 14,
color: AppColors.secondaryText,
fontFamily: 'Inter',
),
),
const SizedBox(height: 4),
Text(
value,
style: const TextStyle(
fontSize: 16,
color: AppColors.text,
fontFamily: 'Inter',
),
),
],
);
}

String _calculateDuration(String startDate, String endDate) {
try {
final start = DateTime.parse(startDate);
final end = DateTime.parse(endDate);
final difference = end.difference(start).inDays + 1;
return '$difference Days';
} catch (e) {
return 'N/A';
}
}
}