import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnnouncementInfoRow extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementInfoRow({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String updateDate = announcement['berita_when_update'] != null
        ? announcement['berita_when_update'].toString().split(' ').first // Get only the date part
        : 'N/A';
    final String authorName = 'HRD'; // You might need to fetch the actual author name
    final String category = 'Announcement'; // You might have a category field in your data

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          updateDate,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.43,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          authorName,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.43,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.tag_outlined, size: 16, color: Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          category,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.43,
          ),
        ),
      ],
    );
  }
}