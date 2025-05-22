import 'package:flutter/material.dart';
import 'status_badge.dart';

enum AttendanceStatus {
  present,
  late,
  absent,
}

class AttendanceRecordCard extends StatelessWidget {
  final String date;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
  final bool isMissingCheckOut;

  const AttendanceRecordCard({
    Key? key,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.isMissingCheckOut = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                  fontFamily: 'Inter',
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          SizedBox(height: 12),
          if (status != AttendanceStatus.absent) ...[
            if (checkIn != null)
              _buildTimeRow(
                Icons.login,
                'Check-in: $checkIn',
                Color(0xFF14B8A6),
              ),
            SizedBox(height: 8),
            if (checkOut != null)
              _buildTimeRow(
                Icons.logout,
                'Check-out: $checkOut',
                Color(0xFFF97316),
              ),
            if (isMissingCheckOut)
              _buildErrorRow('Missing check-out'),
          ] else ...[
            _buildErrorRow('Missing check-in'),
            SizedBox(height: 8),
            _buildErrorRow('Missing check-out'),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildErrorRow(String text) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 20,
          color: Color(0xFFEF4444),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFEF4444),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
