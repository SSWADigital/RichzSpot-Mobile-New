import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class AbsenceHistorySection extends StatelessWidget {
  final List<dynamic> leaveData;

  const AbsenceHistorySection({Key? key, required this.leaveData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Absence History',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          if (leaveData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No absence history available.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaveData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final leave = leaveData[index];
                final String title = leave['jenis_izin'] ?? 'N/A';
                final String status = _getStatusText(leave['izin_status']);
                final ColorPair statusColors = _getStatusColors(leave['izin_status']);
                final String startDate = leave['tanggal_mulai_izin'] != null
                    ? DateFormat('MMM d, y').format(DateTime.parse(leave['tanggal_mulai_izin']))
                    : 'N/A';
                final String endDate = leave['tanggal_selesai_izin'] != null
                    ? DateFormat('MMM d, y').format(DateTime.parse(leave['tanggal_selesai_izin']))
                    : 'N/A';
                final String dateRange = startDate == endDate ? startDate : '$startDate - $endDate';
                final String reason = leave['izin_keterangan'] ?? '-';

                return _buildHistoryCard(
                  title,
                  status,
                  statusColors.backgroundColor,
                  statusColors.textColor,
                  dateRange,
                  reason,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    String title,
    String status,
    Color statusBgColor,
    Color statusTextColor,
    String date,
    String reason,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusTextColor,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.history,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'y':
        return 'approved';
      case 'n':
        return 'pending';
      case 'r':
      case 'x':
        return 'rejected';
      default:
        return 'unknown';
    }
  }

  ColorPair _getStatusColors(String? status) {
    switch (status) {
      case 'y':
        return ColorPair(backgroundColor: const Color(0xFFE8F5E9), textColor: const Color(0xFF2E7D32));
      case 'n':
        return ColorPair(backgroundColor: const Color(0xFFFFF3E0), textColor: const Color(0xFFF57C00));
      case 'r':
      case 'x':
        return ColorPair(backgroundColor: const Color(0xFFFFEBEE), textColor: const Color(0xFFC62828));
      default:
        return ColorPair(backgroundColor: Colors.grey.shade200, textColor: Colors.grey.shade700);
    }
  }
}

class ColorPair {
  final Color backgroundColor;
  final Color textColor;

  ColorPair({required this.backgroundColor, required this.textColor});
}