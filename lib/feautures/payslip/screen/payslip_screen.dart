import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat
import 'package:richzspot/core/constant/app_colors.dart'; // Assuming you have AppColors
import 'package:richzspot/feautures/payslip/screen/payslip_screen_detail.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart';
import 'package:richzspot/feautures/payslip/service/payslip_service.dart';
import 'package:richzspot/feautures/payslip/widgets/salary_card.dart'; // New service

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key}); // Changed to const constructor

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  List<SalarySlip> _salarySlips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSalarySlips();
  }

  Future<void> _fetchSalarySlips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<SalarySlip> fetchedSlips = await SalaryService.getSalarySlips();
      setState(() {
        _salarySlips = fetchedSlips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load salary data. Please try again later. ($e)';
        _isLoading = false;
      });
      // Optionally show a SnackBar or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding( // Use Padding for the Row
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Expanded( // Use Expanded to center the text
                    child: Center(
                      child: Text(
                        'Salary Slip',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Placeholder for spacing if you want the back button to push it to the right
                  const SizedBox(width: 48), // Adjust to match IconButton width + padding
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Data not available"),
                              // ElevatedButton(
                              //   onPressed: _fetchSalarySlips,
                              //   child: const Text('Retry'),
                              // ),
                            ],
                          ),
                        )
                      : _salarySlips.isEmpty
                          ? const Center(
                              child: Text('No salary slips available.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 16, bottom: 35),
                              itemCount: _salarySlips.length,
                              itemBuilder: (context, index) {
                                return SalaryCard(
                                  salarySlip: _salarySlips[index],
                                  onViewDetails: () {
                                    // Pass the full SalarySlip object to the detail screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PayslipDetailScreen(
                                          salarySlip: _salarySlips[index],
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
      ),
    );
  }
}