// lib/feautures/payslip/widgets/payment_details_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your model

class PaymentDetailsSection extends StatelessWidget {
  final SalarySlip salarySlip; // Add this property

  const PaymentDetailsSection({Key? key, required this.salarySlip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final String paymentDate = DateFormat('dd MMMM yyyy').format(salarySlip.gajiTgl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Employee Name', salarySlip.userNamaLengkap),
        _buildDetailRow('Payment Date', paymentDate),
        // Add other relevant payment details if available in your SalarySlip model
        // _buildDetailRow('Bank Name', 'Bank Central Asia (BCA)'),
        // _buildDetailRow('Account Number', 'XXXX-XXXX-1234'),
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