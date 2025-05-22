import 'package:flutter/material.dart';
import '../styles/schedule_styles.dart';

class EventCard extends StatelessWidget {
  final String time;
  final String title;
  final String location;
  final IconData iconData; // Mengganti iconUrl dengan IconData
  final IconData locationIconData; // Mengganti locationIconUrl dengan IconData
  final Color iconColor; // Tambahkan warna untuk icon
  final Color locationIconColor; // Tambahkan warna untuk icon lokasi

  const EventCard({
    Key? key,
    required this.time,
    required this.title,
    required this.location,
    required this.iconData,
    required this.locationIconData,
    this.iconColor = Colors.blueAccent, // Warna default untuk icon
    this.locationIconColor = Colors.grey, // Warna default untuk icon lokasi
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2), // Latar belakang lingkaran untuk icon
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: ScheduleStyles.eventTimeStyle,
                ),
                const SizedBox(height: 9),
                Text(
                  title,
                  style: ScheduleStyles.eventTitleStyle,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      locationIconData,
                      size: 16,
                      color: locationIconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: ScheduleStyles.eventLocationStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}