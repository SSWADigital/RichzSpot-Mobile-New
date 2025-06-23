// lib/feautures/payslip/models/salary_slip.dart

import 'package:intl/intl.dart';

class SalarySlip {
  final String gajiId;
  final String? idUser;
  final double? gajiPokok;
  final double? gajiUangMakan;
  final double? gajiPremiHadir;
  final double? gajiBpjsKes;
  final double? gajiBpjsTk;
  final DateTime? gajiTgl;
  final String? idDep;
  final double? gajiPotongan;
  final double? pph; // <--- UBAH DARI String? MENJADI double?
  final double? totalGaji;
  final String? gajiStatus;
  final String? idHrd;
  final String? gajiKeteranganHrd;
  final String? userNamaLengkap;
  final double? bonus;

  SalarySlip({
    required this.gajiId,
    this.idUser,
    this.gajiPokok,
    this.gajiUangMakan,
    this.gajiPremiHadir,
    this.gajiBpjsKes,
    this.gajiBpjsTk,
    this.gajiTgl,
    this.idDep,
    this.gajiPotongan,
    this.pph, // Tetap di sini
    this.totalGaji,
    this.gajiStatus,
    this.idHrd,
    this.gajiKeteranganHrd,
    this.userNamaLengkap,
    this.bonus,
  });

  factory SalarySlip.fromJson(Map<String, dynamic> json) {
    return SalarySlip(
      gajiId: json['gaji_id'] as String,
      idUser: json['id_user'] as String?,
      gajiPokok: json['gaji_pokok'] != null ? double.tryParse(json['gaji_pokok'].toString()) : null,
      gajiUangMakan: json['gaji_uang_makan'] != null ? double.tryParse(json['gaji_uang_makan'].toString()) : null,
      gajiPremiHadir: json['gaji_premi_hadir'] != null ? double.tryParse(json['gaji_premi_hadir'].toString()) : null,
      gajiBpjsKes: json['gaji_bpjs_kes'] != null ? double.tryParse(json['gaji_bpjs_kes'].toString()) : null,
      gajiBpjsTk: json['gaji_bpjs_tk'] != null ? double.tryParse(json['gaji_bpjs_tk'].toString()) : null,
      gajiTgl: json['gaji_tgl'] != null ? DateTime.tryParse(json['gaji_tgl'] as String) : null,
      idDep: json['id_dep'] as String?,
      gajiPotongan: json['gaji_potongan'] != null ? double.tryParse(json['gaji_potongan'].toString()) : null,
      pph: json['pph'] != null ? double.tryParse(json['pph'].toString()) : null, // <--- UBAH PARSING KE double.tryParse()
      totalGaji: json['total_gaji'] != null ? double.tryParse(json['total_gaji'].toString()) : null,
      gajiStatus: json['gaji_status'] as String?,
      idHrd: json['id_hrd'] as String?,
      gajiKeteranganHrd: json['gaji_keterangan_hrd'] as String?,
      userNamaLengkap: json['user_nama_lengkap'] as String?,
      bonus: json['bonus'] != null ? double.tryParse(json['bonus'].toString()) : null,
    );
  }

  String get payPeriodFormatted {
    if (gajiTgl == null) return 'N/A';
    return DateFormat('MMMM', 'id_ID').format(gajiTgl!);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0'; // Mengubah '\$N/A' menjadi 'Rp 0' atau sesuai keinginan
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0); // Ubah symbol dan decimalDigits agar konsisten
    return formatCurrency.format(amount);
  }

  String get formattedTotalGaji => _formatCurrency(totalGaji);
  String get formattedGajiPokok => _formatCurrency(gajiPokok);
  String get formattedAllowances => _formatCurrency((gajiUangMakan ?? 0.0) + (gajiPremiHadir ?? 0.0));
  String get formattedDeductions {
    double totalDeductions = (gajiPotongan ?? 0.0) + (gajiBpjsKes ?? 0.0) + (gajiBpjsTk ?? 0.0) + (pph ?? 0.0); // Tambahkan pph ke deductions jika itu potongan
    // Perhatikan bahwa PPH biasanya adalah potongan. Jika Anda ingin menampilkannya sebagai nilai positif
    // tapi secara fungsional itu mengurangi gaji, Anda mungkin tidak perlu menambahkan minus di sini
    // jika _buildDetailRow tidak menampilkannya sebagai potongan negatif.
    return _formatCurrency(totalDeductions);
  }
  String get formattedBonus => _formatCurrency(bonus);
}