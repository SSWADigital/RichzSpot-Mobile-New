import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat and NumberFormat
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your model
import 'package:richzspot/feautures/payslip/widgets/current_payslip_card.dart';
import 'package:richzspot/feautures/payslip/widgets/payment_details_section.dart';
import 'package:richzspot/feautures/payslip/widgets/salary_breakdown_section.dart';
import 'package:richzspot/shared/widgets/back_icon.dart'; // Assuming this exists

class PayslipDetailScreen extends StatelessWidget {
  final SalarySlip salarySlip; // Add this property

  const PayslipDetailScreen({super.key, required this.salarySlip}); // Add required constructor

  @override
  Widget build(BuildContext context) {
    // Formatter for total_gaji
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Formatter for date
    final String displayMonthYear = DateFormat('MMMM yyyy').format(salarySlip.gajiTgl);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    // margin: const EdgeInsets.only(top: 44), // Consider if this margin is needed or if SafeArea handles it
                    child: Row(
                      children: [
                        BackIcon(context: context),
                        const SizedBox(width: 16), // Add some spacing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                          children: [
                            const Text(
                              'Salary Slip',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                height: 1.4,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayMonthYear, // Use the formatted date from the passed salarySlip
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4B5563),
                                height: 1.5,
                                fontFamily: 'Inter',
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
                        // Pass relevant salary slip data to CurrentPayslipCard
                        CurrentPayslipCard(
                          totalSalary: salarySlip.totalGaji,
                          gajiId: salarySlip.gajiId, // Pass gajiId if needed for download
                        ),
                        const SizedBox(height: 32),
                        // Pass relevant salary slip data to SalaryBreakdownSection
                        SalaryBreakdownSection(salarySlip: salarySlip),
                        const SizedBox(height: 32),
                        // Pass relevant salary slip data to PaymentDetailsSection
                        PaymentDetailsSection(salarySlip: salarySlip),
                        const SizedBox(height: 88),
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