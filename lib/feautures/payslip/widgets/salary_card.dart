import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/salary_slip.dart';
// Assuming AppColors is defined here or in a similar path
import 'package:richzspot/core/constant/app_colors.dart'; // Adjust path if needed



class SalaryCard extends StatelessWidget {
  final SalarySlip salarySlip;
  final VoidCallback onViewDetails;

  const SalaryCard({
    Key? key,
    required this.salarySlip,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp',   // Rupiah symbol
      decimalDigits: 0, // No decimal digits for Rupiah (typically)
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // You might want to add a subtle shadow here for better visual separation
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Replaced Image.network with Icon for calendar
                  Icon(
                    Icons.calendar_month, // Or Icons.date_range, Icons.event
                    size: 24, // Slightly larger for better visibility
                    color: AppColors.primaryBlue, // Use your primary color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${salarySlip.month} ${salarySlip.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              // Replaced Image.network with Icon for download
              GestureDetector( // Make the download icon tappable if it performs an action
                onTap: () {
                  // Handle download logic here, e.g.,
                  // print('Download requested for ${salarySlip.month} ${salarySlip.year}');
                },
                child: Icon(
                  Icons.download, // Or Icons.cloud_download
                  size: 24, // Slightly larger for better visibility
                  color: AppColors.primaryBlue, // Use your primary color
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Replaced Image.network with Icon for money
              Icon(
                Icons.attach_money, // Or Icons.monetization_on, Icons.payments
                size: 24, // Slightly larger for better visibility
                color: AppColors.primaryBlue, // Use your primary color
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormatter.format(salarySlip.totalGaji),
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Inter',
                  height: 2, // You might adjust or remove height for better alignment
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onViewDetails,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 17,
                horizontal: 70, // Keep if you want fixed width, otherwise remove
              ),
              // Use AppColors.primary for the button text color
              child: Text(
                'View Details',
                style: TextStyle(
                  color: AppColors.primaryBlue, // Use your primary color for text
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

