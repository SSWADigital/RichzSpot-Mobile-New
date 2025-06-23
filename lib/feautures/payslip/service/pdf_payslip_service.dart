// lib/services/payslip_pdf_service.dart
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart'; // Import your SalarySlip model
import 'dart:convert'; // For jsonDecode

class PayslipPdfService {
  // _apiBaseUrl tidak lagi dibutuhkan jika App.apiBaseUrl digunakan
  // final String _apiBaseUrl = 'http://103.157.97.152/richzspot/api';

  Future<SalarySlip> fetchSalarySlip(String gajiId) async {
    final String? token = await AppStorage.getToken(); // Pastikan ini mengembalikan token yang benar

    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    
    // Menggunakan App.apiBaseUrl seperti di kode yang Anda berikan
    final response = await http.get(
      Uri.parse('${App.apiBaseUrl}/Gaji/getGajiById/$gajiId'),
      headers: headers,
    );

    print('Fetching salary slip raw response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        // <--- PERUBAHAN UTAMA DI SINI ---
        // Langsung decode body respons menjadi Map,
        // dan langsung parsing ke SalarySlip.fromJson
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return SalarySlip.fromJson(jsonResponse);
      } catch (e) {
        // Tangani jika parsing JSON gagal (misalnya, respons bukan JSON valid)
        throw Exception('Failed to parse salary slip data from JSON: $e');
      }
    } else {
      // Tangani status code yang bukan 200
      throw Exception('Failed to load salary slip. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Metode generateAndOpenPdf (tidak perlu perubahan di sini karena ia memanggil fetchSalarySlip)
  Future<void> generateAndOpenPdf(String gajiId) async {
    try {
      final SalarySlip salarySlip = await fetchSalarySlip(gajiId);
      
      final pdf = pw.Document();

      final NumberFormat currencyFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );

      pw.Widget _buildPdfDetailRow(String label, String value) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                value,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Payslip', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Employee: ${salarySlip.userNamaLengkap ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Pay Period: ${salarySlip.payPeriodFormatted}', style: const pw.TextStyle(fontSize: 12)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                
                pw.Text('Salary Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                _buildPdfDetailRow('Basic Salary', currencyFormatter.format(salarySlip.gajiPokok ?? 0.0)),
                _buildPdfDetailRow('Meal Allowance', currencyFormatter.format(salarySlip.gajiUangMakan ?? 0.0)),
                _buildPdfDetailRow('Attendance Premium', currencyFormatter.format(salarySlip.gajiPremiHadir ?? 0.0)),
                _buildPdfDetailRow('BPJS Kesehatan', currencyFormatter.format(salarySlip.gajiBpjsKes ?? 0.0)),
                _buildPdfDetailRow('BPJS Ketenagakerjaan', currencyFormatter.format(salarySlip.gajiBpjsTk ?? 0.0)),
                _buildPdfDetailRow('PPH', currencyFormatter.format(salarySlip.pph ?? 0.0)),
                _buildPdfDetailRow('Bonus', currencyFormatter.format(salarySlip.bonus ?? 0.0)),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Net Salary',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      currencyFormatter.format(salarySlip.totalGaji ?? 0.0),
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/payslip_${gajiId}.pdf');
      await file.writeAsBytes(await pdf.save());

      await OpenFilex.open(file.path);

    } catch (e) {
      print('Error generating or opening PDF: $e');
      rethrow;
    }
  }
}