import 'package:flutter/material.dart';
import 'attendance_record_card.dart';

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const StatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = Color(0xFFE6F9F1);
        textColor = Color(0xFF14B8A6);
        text = 'present';
        break;
      case AttendanceStatus.late:
        backgroundColor = Color(0xFFFFE6D5);
        textColor = Color(0xFFF97316);
        text = 'late';
        break;
      case AttendanceStatus.absent:
        backgroundColor = Color(0xFFFFE6E6);
        textColor = Color(0xFFEF4444);
        text = 'absent';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
