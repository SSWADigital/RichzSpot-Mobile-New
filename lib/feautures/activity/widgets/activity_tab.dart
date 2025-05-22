// lib/feautures/activity/widgets/activity_tab.dart
import 'package:flutter/material.dart';

class ActivityTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityTab({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5EEFF) : Colors.transparent, // Warna latar belakang saat terpilih
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500, // Slightly bolder for selected text
            color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF4B5563), // Warna teks saat terpilih vs tidak
          ),
        ),
      ),
    );
  }
}