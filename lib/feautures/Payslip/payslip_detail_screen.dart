import 'package:flutter/material.dart';
import 'payslip_list_screen.dart'; // Import model data payslip dari file lain

// === Payslip Detail Screen ===
class PayslipDetailScreen extends StatefulWidget {
  final EmployeePayslip payslip;

  const PayslipDetailScreen({super.key, required this.payslip});

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  final TextEditingController _bonusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bonusController.text = "300"; // Default bonus
  }

  @override
  Widget build(BuildContext context) {
    // === Komponen Gaji ===
    double baseSalary = 4000;
    double allowances = 1000;
    double deductions = 100;
    double bonus = double.tryParse(_bonusController.text) ?? 0;
    double netSalary = baseSalary + allowances + bonus - deductions;

    // === UI Utama ===
    return Scaffold(
      // === AppBar ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Approval Payslip",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      // === Body ===
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // === Informasi Karyawan ===
          _buildInfoCard(widget.payslip),

          // === Rincian Gaji ===
          _buildAmountTile("Base Salary", "\$4,000.00"),
          _buildAmountTile("Allowances", "\$1,000.00"),
          _buildBonusField(),
          _buildAmountTile("Deductions", "-\$100.00", isNegative: true),
          _buildAmountTile("Net Salary", "\$${netSalary.toStringAsFixed(2)}", isBold: true),

          SizedBox(height: 24),

          // === Tombol Aksi ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Reject (Merah)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text("Reject"),
                ),
              ),
              SizedBox(width: 16),
              // Tombol Approve (Hijau)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text("Approve"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // === Widget: Kartu Informasi Karyawan ===
  Widget _buildInfoCard(EmployeePayslip payslip) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payslip.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Employee ID: ${payslip.employeeId}"),
          Text("Department: ${payslip.department}"),
          Text("Pay Period: ${payslip.payPeriod}"),
        ],
      ),
    );
  }

  // === Widget: Box Jumlah Gaji ===
  Widget _buildAmountTile(String title, String amount,
      {bool isNegative = false, bool isBold = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: isNegative ? Colors.red : Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ]),
    );
  }

  // === Widget: Bonus Input ===
  Widget _buildBonusField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Bonus",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        TextField(
          controller: _bonusController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Bonus Amount",
          ),
          onChanged: (_) => setState(() {}), // Update nilai net salary saat bonus berubah
        ),
      ]),
    );
  }
}
