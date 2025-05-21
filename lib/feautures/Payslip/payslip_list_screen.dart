import 'package:flutter/material.dart';
import 'payslip_detail_screen.dart';

void main() {
  runApp(MaterialApp(
    home: ApprovalPayslipScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// Model data untuk slip gaji karyawan
class EmployeePayslip {
  final String name;
  final String employeeId;
  final String department;
  final String payPeriod;
  final String totalSalary;
  final String status;

  EmployeePayslip({
    required this.name,
    required this.employeeId,
    required this.department,
    required this.payPeriod,
    required this.totalSalary,
    required this.status,
  });
}

class ApprovalPayslipScreen extends StatefulWidget {
  @override
  _ApprovalPayslipScreenState createState() => _ApprovalPayslipScreenState();
}

class _ApprovalPayslipScreenState extends State<ApprovalPayslipScreen> {
  // Data dummy list payslip
  List<EmployeePayslip> payslips = [
    EmployeePayslip(
      name: 'John Anderson',
      employeeId: 'EMP001',
      department: 'Engineering',
      payPeriod: 'April 2025',
      totalSalary: '\$5200',
      status: 'Pending',
    ),
    EmployeePayslip(
      name: 'Sarah Wilson',
      employeeId: 'EMP002',
      department: 'Marketing',
      payPeriod: 'April 2025',
      totalSalary: '\$4800',
      status: 'Approved',
    ),
    EmployeePayslip(
      name: 'Michael Brown',
      employeeId: 'EMP003',
      department: 'Sales',
      payPeriod: 'April 2025',
      totalSalary: '\$5500',
      status: 'Rejected',
    ),
  ];

  // Variabel untuk pilihan filter (saat ini belum implementasi filter fungsional)
  String selectedDepartment = "All Departments";
  String selectedMonth = "April 2025";
  String selectedStatus = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Implementasi AppBar dengan title "Approval Payslip" dan ikon filter
      appBar: AppBar(
        title: Text(
          'Approval Payslip',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {}, // Bisa diisi fungsi filter nanti
          )
        ],
      ),

      // Body utama berisi search bar, filter chips, dan list payslip
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2. Tambahkan search bar (TextField) untuk nama karyawan
            TextField(
              decoration: InputDecoration(
                hintText: 'Search employee name',
                prefixIcon: Icon(Icons.search),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Bisa tambahkan onChanged untuk search fungsional nanti
            ),

            SizedBox(height: 12),

            // 3. Tambahkan filter menggunakan Wrap + ChoiceChip
            Wrap(
              spacing: 8.0,
              children: [
                // ChoiceChip untuk filter "All Departments"
                ChoiceChip(
                  label: Text("All Departments",
                      style: TextStyle(color: Colors.white)),
                  selected: true,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.blue,
                  showCheckmark: false,
                  onSelected: (_) {},
                ),

                // ChoiceChip untuk filter bulan "April 2025"
                ChoiceChip(
                  label:
                      Text("April 2025", style: TextStyle(color: Colors.black)),
                  selected: false,
                  selectedColor: Colors.grey.shade200,
                  backgroundColor: Colors.grey.shade200,
                  showCheckmark: false,
                  onSelected: (_) {},
                ),

                // ChoiceChip untuk filter status "All"
                ChoiceChip(
                  label:
                      Text("Status: All", style: TextStyle(color: Colors.black)),
                  selected: false,
                  selectedColor: Colors.grey.shade200,
                  backgroundColor: Colors.grey.shade200,
                  showCheckmark: false,
                  onSelected: (_) {},
                ),
              ],
            ),

            SizedBox(height: 16),

            // List payslip dengan ListView.builder dan komponen PayslipItemCard
            Expanded(
              child: ListView.builder(
                itemCount: payslips.length,
                itemBuilder: (context, index) {
                  return PayslipItemCard(
                    payslip: payslips[index],
                    onView: () {
                      // 4. Navigasi ke PayslipDetailScreen saat tombol View ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PayslipDetailScreen(payslip: payslips[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen kartu payslip yang menampilkan info lengkap dan tombol View
class PayslipItemCard extends StatelessWidget {
  final EmployeePayslip payslip;
  final VoidCallback onView;

  const PayslipItemCard({required this.payslip, required this.onView});

  // Fungsi untuk warna background badge status
  Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green.shade100;
      case "Rejected":
        return Colors.red.shade100;
      case "Pending":
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  // Fungsi untuk warna teks status badge
  Color getStatusTextColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3, // Beri sedikit bayangan supaya card lebih hidup
      color: Colors.white, // Warna card putih agar tidak terlalu abu-abu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama & Status dengan badge warna
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(payslip.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(payslip.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payslip.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: getStatusTextColor(payslip.status),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Baris dengan dua kolom info: Employee ID & Pay Period, Department & Total Salary
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Employee ID", style: TextStyle(color: Colors.grey)),
                      Text(payslip.employeeId),
                      SizedBox(height: 8),
                      Text("Pay Period", style: TextStyle(color: Colors.grey)),
                      Text(payslip.payPeriod),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Department", style: TextStyle(color: Colors.grey)),
                      Text(payslip.department),
                      SizedBox(height: 8),
                      Text("Total Salary", style: TextStyle(color: Colors.grey)),
                      Text(payslip.totalSalary),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Tombol View untuk navigasi ke detail slip gaji
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "View",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
