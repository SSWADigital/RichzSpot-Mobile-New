// lib/feautures/payslip/screens/approval_payslip_screen.dart
import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart';
import 'package:richzspot/feautures/payslip/screen/approval_payslip_detail_screen.dart';
import 'package:richzspot/feautures/payslip/service/payslip_service.dart';
import 'package:richzspot/feautures/payslip/widgets/payslip_card.dart';// Import detail screen
import 'package:intl/intl.dart'; // Untuk memformat bulan/tahun pada filter

class ApprovalPayslipScreen extends StatefulWidget {
  const ApprovalPayslipScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalPayslipScreen> createState() => _ApprovalPayslipScreenState();
}

class _ApprovalPayslipScreenState extends State<ApprovalPayslipScreen> {
  final SalaryService _apiService = SalaryService(); // Inisialisasi ApiService
  List<SalarySlip> _allSalarySlips = [];
  List<SalarySlip> _filteredSalarySlips = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  // Filter states
  String _selectedDepartment = 'All Departments';
  String _selectedMonthYear = 'All Periods'; // Format: "April 2025"
  String _selectedStatus = 'All Status'; // "All Status", "Pending", "Approved", "Rejected"

  // Untuk menyimpan daftar unik departemen dan periode
  List<String> _availableDepartments = ['All Departments'];
  List<String> _availableMonthYears = ['All Periods'];

  @override
  void initState() {
    super.initState();
    _fetchPayslips();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil data payslip
  Future<void> _fetchPayslips() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<SalarySlip> data = await _apiService.getApprovalGaji();
      setState(() {
        _allSalarySlips = data;
        _populateFilters(data); // Populate filter options
        _filterPayslips(); // Apply initial filter (which is no filter)
      });
    } catch (e) {
      print('Error fetching approval gaji: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load payslips: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFilters(List<SalarySlip> data) {
    Set<String> departments = {'All Departments'};
    Set<String> monthYears = {'All Periods'};

    for (var slip in data) {
      if (slip.idDep != null) {
        departments.add(slip.idDep!);
      }
      if (slip.payPeriodFormatted != 'N/A') {
        monthYears.add(slip.payPeriodFormatted);
      }
    }

    setState(() {
      _availableDepartments = departments.toList()..sort();
      _availableMonthYears = monthYears.toList()..sort();
    });
  }

  void _onSearchChanged() {
    _filterPayslips(); // Panggil filter setiap kali teks pencarian berubah
  }

  void _filterPayslips() {
    List<SalarySlip> tempFilteredList = _allSalarySlips;
    final String searchQuery = _searchController.text.toLowerCase();

    // Apply search query filter
    if (searchQuery.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((slip) {
        final String userName = (slip.userNamaLengkap ?? '').toLowerCase();
        final String userId = (slip.idUser ?? '').toLowerCase();
        return userName.contains(searchQuery) || userId.contains(searchQuery);
      }).toList();
    }

    // Apply Department filter
    if (_selectedDepartment != 'All Departments') {
      tempFilteredList = tempFilteredList.where((slip) => slip.idDep == _selectedDepartment).toList();
    }

    // Apply Month/Year filter
    if (_selectedMonthYear != 'All Periods') {
      tempFilteredList = tempFilteredList.where((slip) => slip.payPeriodFormatted == _selectedMonthYear).toList();
    }

    // Apply Status filter
    if (_selectedStatus != 'All Status') {
      String targetStatus = '';
      if (_selectedStatus == 'Pending') {
        targetStatus = 'p';
      } else if (_selectedStatus == 'Approved') {
        targetStatus = 'y';
      } else if (_selectedStatus == 'Rejected') {
        targetStatus = 'n';
      }
      tempFilteredList = tempFilteredList.where((slip) => slip.gajiStatus == targetStatus).toList();
    }

    setState(() {
      _filteredSalarySlips = tempFilteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Approval Payslip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Sesuaikan warna AppBar
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employee name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    context,
                    label: _selectedDepartment,
                    options: _availableDepartments,
                    onSelected: (value) {
                      setState(() {
                        _selectedDepartment = value;
                        _filterPayslips();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    context,
                    label: _selectedMonthYear,
                    options: _availableMonthYears,
                    onSelected: (value) {
                      setState(() {
                        _selectedMonthYear = value;
                        _filterPayslips();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    context,
                    label: _selectedStatus,
                    options: ['All Status', 'Pending', 'Approved', 'Rejected'],
                    onSelected: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _filterPayslips();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredSalarySlips.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty &&
                                  _selectedDepartment == 'All Departments' &&
                                  _selectedMonthYear == 'All Periods' &&
                                  _selectedStatus == 'All Status'
                              ? 'No payslips awaiting approval.'
                              : 'No matching payslips found.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredSalarySlips.length,
                        itemBuilder: (context, index) {
                          final SalarySlip salarySlip = _filteredSalarySlips[index];
                          return PayslipCard(
                            salarySlip: salarySlip,
                            // Properto lain yang mungkin dibutuhkan oleh PayslipCard (jika tidak langsung dari SalarySlip)
                            name: salarySlip.userNamaLengkap ?? 'N/A',
                            employeeId: salarySlip.idUser ?? 'N/A',
                            department: salarySlip.idDep ?? 'N/A', // Assuming idDep is directly the department name/id
                            payPeriod: salarySlip.payPeriodFormatted,
                            totalSalary: salarySlip.formattedTotalGaji,
                            status: salarySlip.gajiStatus ?? 'unknown',
                            onStatusChanged: () {
                              _fetchPayslips(); // Refresh data setelah kembali dari detail
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApprovalPayslipDetailScreen(
                                    salarySlip: salarySlip,
                                    onStatusChanged: () {
                                      _fetchPayslips(); // Memuat ulang daftar saat status berubah
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Helper widget for filter buttons
  Widget _buildFilterButton(
      BuildContext context, {
        required String label,
        required List<String> options,
        required Function(String) onSelected,
      }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}