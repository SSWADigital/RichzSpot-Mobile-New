// lib/feautures/payslip/widgets/salary_breakdown_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your model

class SalaryBreakdownSection extends StatelessWidget {
  final SalarySlip salarySlip;

  const SalaryBreakdownSection({Key? key, required this.salarySlip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salary Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
            'Basic Salary', currencyFormatter.format(salarySlip.gajiPokok)),
        _buildDetailRow('Meal Allowance', currencyFormatter.format(salarySlip.gajiUangMakan)),
        _buildDetailRow('Attendance Premium', currencyFormatter.format(salarySlip.gajiPremiHadir)),
        _buildDetailRow('BPJS Kesehatan', currencyFormatter.format(salarySlip.gajiBpjsKes)),
        _buildDetailRow('BPJS Ketenagakerjaan', currencyFormatter.format(salarySlip.gajiBpjsTk)),
        _buildDetailRow('PPH', currencyFormatter.format(salarySlip.pph)),
        // Add other components if necessary
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}