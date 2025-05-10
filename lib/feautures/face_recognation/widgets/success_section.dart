import 'package:flutter/material.dart';

class SuccessSection extends StatelessWidget {
  const SuccessSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Image.asset(
            'https://cdn.builder.io/api/v1/image/assets/TEMP/6b169b629341c5531519909256591aa930136caa?placeholderIfAbsent=true',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 7),
            child: Text(
              'Check-In Successful',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF34C759),
                height: 1.4,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 6),
            child: Text(
              'Checked in at 06:00 PM',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoSection('Name', 'Candra Vradita'),
                const SizedBox(height: 12),
                _buildInfoSection('Employee ID', 'EMP1234'),
                const SizedBox(height: 12),
                _buildInfoSection('Department', 'Project'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 6),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
