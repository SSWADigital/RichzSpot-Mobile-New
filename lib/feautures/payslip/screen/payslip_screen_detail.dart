import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat and NumberFormat
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your model
import 'package:richzspot/feautures/payslip/widgets/current_payslip_card.dart';
import 'package:richzspot/feautures/payslip/widgets/payment_details_section.dart';
import 'package:richzspot/feautures/payslip/widgets/salary_breakdown_section.dart';
import 'package:richzspot/shared/widgets/back_icon.dart'; // Assuming this exists

// Ini adalah perbaikan untuk PayslipDetailScreen yang baru Anda berikan
class PayslipDetailScreen extends StatelessWidget {
  final SalarySlip salarySlip;

  const PayslipDetailScreen({super.key, required this.salarySlip});

  @override
  Widget build(BuildContext context) {
    // Formatter for total_gaji (sebenarnya sudah ada di SalarySlip model sebagai formattedTotalGaji)
    // final NumberFormat currencyFormatter = NumberFormat.currency(
    //   locale: 'id_ID',
    //   symbol: 'Rp',
    //   decimalDigits: 0,
    // );

    // Formatter for date
    // Menggunakan getter dari SalarySlip untuk format yang sudah ditentukan
    final String displayMonthYear = salarySlip.gajiTgl != null
        ? DateFormat('MMMM yyyy').format(salarySlip.gajiTgl!)
        : 'N/A'; // Handle null date gracefully

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              // constraints: const BoxConstraints(maxWidth: 390), // Batasi lebar untuk tampilan tablet/desktop
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    // margin: const EdgeInsets.only(top: 44), // SafeArea sudah menangani padding atas
                    child: Row(
                      children: [
                        // back_icon.dart mungkin memiliki constructor berbeda
                        // Jika BackIcon hanyalah IconButton(onPressed: Navigator.pop),
                        // Anda bisa menggantinya secara langsung:
                        // IconButton(
                        //   icon: const Icon(Icons.arrow_back_ios),
                        //   onPressed: () => Navigator.pop(context),
                        // ),
                        // Atau jika BackIcon butuh context:
                        BackIcon(context: context), // Asumsi BackIcon butuh context di constructor
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Salary Slip',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                // height: 1.4, // Hapus atau gunakan nilai yang lebih kecil, e.g., 1.2
                                // fontFamily: 'Inter', // Hapus jika tidak diatur di pubspec.yaml
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayMonthYear,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4B5563),
                                // height: 1.5, // Hapus atau gunakan nilai yang lebih kecil
                                // fontFamily: 'Inter', // Hapus jika tidak diatur di pubspec.yaml
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Pastikan properti yang dilewatkan ke CurrentPayslipCard sudah sesuai
                        CurrentPayslipCard(
                          totalSalary: salarySlip.totalGaji ?? 0.0, // Memberikan default jika null
                          gajiId: salarySlip.gajiId, // gajiId tidak boleh null
                        ),
                        const SizedBox(height: 32),
                        SalaryBreakdownSection(salarySlip: salarySlip),
                        const SizedBox(height: 32),
                        PaymentDetailsSection(salarySlip: salarySlip),
                        const SizedBox(height: 88), // Memberikan ruang di bagian bawah
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}