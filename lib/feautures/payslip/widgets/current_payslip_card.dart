import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat
import 'download_button.dart'; // Your existing DownloadButton

class CurrentPayslipCard extends StatelessWidget {
  final double totalSalary;
  final String gajiId; // Pass gajiId if needed for download or specific details

  const CurrentPayslipCard({
    Key? key,
    required this.totalSalary,
    required this.gajiId, // Make sure you receive this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
            color: Colors.black.withOpacity(0.1),
          ),
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Payslip',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(totalSalary), // Use the passed totalSalary
            style: const TextStyle(
              fontSize: 30,
              color: Colors.black,
              height: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Net Salary',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          DownloadButton(
            
          ),
        ],
      ),
    );
  }
}