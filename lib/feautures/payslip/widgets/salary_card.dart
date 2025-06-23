import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/feautures/payslip/service/pdf_payslip_service.dart' show PayslipPdfService;
import '../models/salary_slip.dart';
import 'package:richzspot/core/constant/app_colors.dart'; // Adjust path if needed
// import 'package:richzspot/services/payslip_pdf_service.dart'; // <--- Import PayslipPdfService

class SalaryCard extends StatefulWidget { // <--- UBAH MENJADI StatefulWidget
  final SalarySlip salarySlip;
  final VoidCallback onViewDetails;

  const SalaryCard({
    Key? key,
    required this.salarySlip,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  State<SalaryCard> createState() => _SalaryCardState(); // <--- BUAT STATE BARU
}

class _SalaryCardState extends State<SalaryCard> { // <--- DEFINISIKAN STATE
  bool _isDownloading = false; // State untuk indikator loading
  final PayslipPdfService _pdfService = PayslipPdfService(); // <--- Inisialisasi service PDF

  Future<void> _downloadPayslip() async {
    setState(() {
      _isDownloading = true; // Set loading to true
    });

    try {
      // Panggil metode generateAndOpenPdf dari service
      // Menggunakan widget.salarySlip.gajiId untuk mengambil ID gaji
      await _pdfService.generateAndOpenPdf(widget.salarySlip.gajiId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payslip downloaded and opened successfully!')),
      );
    } catch (e) {
      print('Download failed: $e'); // Log error untuk debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download payslip: ${e.toString()}'),
          backgroundColor: Colors.red, // Warna merah untuk error
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false; // Set loading to false setelah selesai (berhasil/gagal)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.salarySlip.payPeriodFormatted}', // Menggunakan widget.salarySlip
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _isDownloading ? null : _downloadPayslip, // <--- Panggil fungsi download
                child: _isDownloading
                    ? SizedBox( // <--- Tampilkan loading indicator saat mendownload
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Icon( // <--- Tampilkan icon download saat tidak mendownload
                        Icons.download,
                        size: 24,
                        color: AppColors.primary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.salarySlip.formattedTotalGaji, // Menggunakan widget.salarySlip
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onViewDetails, // Menggunakan widget.onViewDetails
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}