// lib/feautures/activity/widgets/activity_timeline_item.dart
import 'package:flutter/material.dart';

class ActivityTimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final IconData icon; // Menggunakan IconData bukan String url
  final bool isLast; // Untuk menentukan apakah garis vertikal perlu dilanjutkan

  const ActivityTimelineItem({
    Key? key,
    required this.time,
    required this.title,
    required this.icon,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 48, // Diperbesar: Ukuran lingkaran ikon (dari 32)
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5EEFF), // Warna latar belakang ikon
                ),
                child: Icon(
                  icon,
                  size: 28, // Diperbesar: Ukuran ikon di dalam lingkaran (dari 16)
                  color: const Color(0xFF007AFF), // Warna ikon
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2, // Ketebalan garis (tetap sama)
                    color: const Color(0xFFE5EEFF), // Warna garis
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20), // Diperbesar: Jarak antara ikon/garis dan teks (dari 16)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16, // Diperbesar: Ukuran teks waktu (dari 14)
                    color: Color(0xFF6B7280),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6), // Diperbesar: Jarak antara waktu dan judul (dari 4)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, // Diperbesar: Ukuran teks judul (dari 16)
                    color: Color(0xFF111827),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLast) const SizedBox(height: 32), // Diperbesar: Spasi antar item (dari 24)
              ],
            ),
          ),
        ],
      ),
    );
  }
}