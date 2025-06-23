// lib/feautures/payslip/widgets/payment_details_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your model

class PaymentDetailsSection extends StatelessWidget {
  final SalarySlip salarySlip; // Add this property

  const PaymentDetailsSection({Key? key, required this.salarySlip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NumberFormat tidak diperlukan di sini karena kita menggunakan getter dari SalarySlip
    // final NumberFormat currencyFormatter = NumberFormat.currency(
    //   locale: 'id_ID',
    //   symbol: 'Rp',
    //   decimalDigits: 0,
    // );

    // Menggunakan getter payPeriodFormatted dari SalarySlip untuk tanggal
    // Asumsi gajiTgl di SalarySlip adalah tanggal pembayaran.
    final String paymentDate = salarySlip.gajiTgl != null
        ? DateFormat('dd MMMM yyyy').format(salarySlip.gajiTgl!)
        : 'N/A'; // Handle null date

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
        _buildDetailRow('Employee Name', salarySlip.userNamaLengkap ?? 'N/A'),
        // _buildDetailRow('Employee ID', salarySlip.idUser ?? 'N/A'), // Tambahkan Employee ID
        // _buildDetailRow('Department', salarySlip. ?? 'N/A'), // Tambahkan Department
        _buildDetailRow('Pay Period', salarySlip.payPeriodFormatted), // Ambil dari getter
        _buildDetailRow('Payment Date', paymentDate),
        // Tambahkan detail lain jika ada di model SalarySlip Anda
        // Misalnya:
        // _buildDetailRow('Bank Name', salarySlip.bankName ?? 'N/A'),
        // _buildDetailRow('Account Number', salarySlip.accountNumber ?? 'N/A'),
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
          Expanded( // Gunakan Expanded agar teks value tidak overflow
            child: Text(
              value,
              textAlign: TextAlign.right, // Rata kanan untuk value
              style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
            ),
          ),
        ],
      ),
    );
  }
}