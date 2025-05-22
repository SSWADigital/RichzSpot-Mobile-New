import 'package:flutter/material.dart';
import '../models/user_model.dart';

class SuccessCheckInWidget extends StatelessWidget {
  final String checkInTime;
  final UserModel user;

  const SuccessCheckInWidget({
    super.key,
    required this.checkInTime,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Success icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 30,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Success text
        Text(
          'Check-In Successful',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Check-in time
        Text(
          'Checked in at $checkInTime',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 30),
        
        // User info card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('Name', user.name),
              const SizedBox(height: 16),
              _buildInfoRow('Employee ID', user.employeeId),
              const SizedBox(height: 16),
              _buildInfoRow('Department', user.department),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}