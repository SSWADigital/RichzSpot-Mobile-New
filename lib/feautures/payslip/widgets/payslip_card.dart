import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart'; // Pastikan path ini benar
import 'package:richzspot/feautures/payslip/models/salary_slip.dart';
import 'package:richzspot/feautures/payslip/screen/approval_payslip_detail_screen.dart';// Pastikan path ini benar

class PayslipCard extends StatelessWidget {
  final SalarySlip salarySlip;
  // Properti ini bisa dihapus jika semua data diambil dari salarySlip
  final String name;
  final String employeeId;
  final String department;
  final String payPeriod;
  final String totalSalary;
  final String status;
  final VoidCallback? onStatusChanged; // Callback untuk memberitahu screen induk

  const PayslipCard({
    Key? key,
    required this.salarySlip,
    required this.name, // Akan diambil dari salarySlip.userNamaLengkap
    required this.employeeId, // Akan diambil dari salarySlip.idUser
    required this.department, // Akan diambil dari salarySlip.idDep
    required this.payPeriod, // Akan diambil dari salarySlip.payPeriodFormatted
    required this.totalSalary, // Akan diambil dari salarySlip.formattedTotalGaji
    required this.status, // Akan diambil dari salarySlip.gajiStatus
    this.onStatusChanged, required Null Function() onTap,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) { // Pastikan case-insensitive
      case 'p': // pending
        return Colors.yellow.shade800;
      case 'y': // approved
        return Colors.green;
      case 'n': // rejected
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) { // Pastikan case-insensitive
      case 'p':
        return Colors.yellow.shade100;
      case 'y':
        return Colors.green.shade100;
      case 'n':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'p':
        return 'Pending';
      case 'y':
        return 'Approved';
      case 'n':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salarySlip.userNamaLengkap ?? 'N/A', // Ambil dari salarySlip
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(salarySlip.gajiStatus ?? 'unknown'), // Ambil dari salarySlip
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    _getDisplayStatus(salarySlip.gajiStatus ?? 'unknown'), // Tampilkan status yang mudah dibaca
                    style: TextStyle(
                      color: _getStatusColor(salarySlip.gajiStatus ?? 'unknown'),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee ID',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salarySlip.idUser ?? 'N/A', // Ambil dari salarySlip
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salarySlip.idDep ?? 'N/A', // Ambil dari salarySlip
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay Period',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salarySlip.payPeriodFormatted, // Ambil dari salarySlip
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Salary',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salarySlip.formattedTotalGaji, // Ambil dari salarySlip
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApprovalPayslipDetailScreen(
                        salarySlip: salarySlip, // Kirim objek SalarySlip utuh
                        onStatusChanged: onStatusChanged, // Teruskan callback
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}