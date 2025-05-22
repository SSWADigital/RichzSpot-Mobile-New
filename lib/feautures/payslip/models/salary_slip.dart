// lib/feautures/payslip/models/salary_slip.dart
import 'package:intl/intl.dart'; // Import for date parsing

class SalarySlip {
  final String gajiId;
  final String idUser;
  final double gajiPokok;
  final double gajiUangMakan;
  final double gajiPremiHadir;
  final double gajiBpjsKes;
  final double gajiBpjsTk;
  final DateTime gajiTgl; // Changed to DateTime
  final String idDep;
  final double gajiPotongan;
  final double pph;
  final double totalGaji;
  final String userNamaLengkap;

  // These properties are not in your API, so we'll use Icons directly in the UI
  // final String calendarIconUrl;
  // final String downloadIconUrl;
  // final String moneyIconUrl;

  SalarySlip({
    required this.gajiId,
    required this.idUser,
    required this.gajiPokok,
    required this.gajiUangMakan,
    required this.gajiPremiHadir,
    required this.gajiBpjsKes,
    required this.gajiBpjsTk,
    required this.gajiTgl,
    required this.idDep,
    required this.gajiPotongan,
    required this.pph,
    required this.totalGaji,
    required this.userNamaLengkap,
    // this.calendarIconUrl = '', // Default to empty string if not used
    // this.downloadIconUrl = '',
    // this.moneyIconUrl = '',
  });

  factory SalarySlip.fromJson(Map<String, dynamic> json) {
    return SalarySlip(
      gajiId: json['gaji_id'] as String,
      idUser: json['id_user'] as String,
      // Parse numeric strings to double
      gajiPokok: double.parse(json['gaji_pokok'] as String),
      gajiUangMakan: double.parse(json['gaji_uang_makan'] as String),
      gajiPremiHadir: double.parse(json['gaji_premi_hadir'] as String),
      gajiBpjsKes: double.parse(json['gaji_bpjs_kes'] as String),
      gajiBpjsTk: double.parse(json['gaji_bpjs_tk'] as String),
      // Parse date string to DateTime
      gajiTgl: DateTime.parse(json['gaji_tgl'] as String),
      idDep: json['id_dep'] as String,
      gajiPotongan: double.parse(json['gaji_potongan'] as String),
      pph: double.parse(json['pph'] as String),
      totalGaji: double.parse(json['total_gaji'] as String),
      userNamaLengkap: json['user_nama_lengkap'] as String,
    );
  }

  // Helper getters to format date for display
  String get month {
    return DateFormat('MMMM').format(gajiTgl);
  }

  String get year {
    return DateFormat('yyyy').format(gajiTgl);
  }
}