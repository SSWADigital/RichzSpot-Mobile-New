// lib/feautures/payslip/services/salary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart'; // Make sure App.apiBaseUrl is defined here
import 'package:richzspot/core/storage/app_storage.dart'; // To get the token
import '../models/salary_slip.dart';

class SalaryService {
  static const String _baseUrl = App.apiBaseUrl;
  
   // Use your base URL

  static Future<List<SalarySlip>> getSalarySlips() async {
    final url = Uri.parse('${_baseUrl}Gaji/gajiuser');
    final String? token = await AppStorage.getToken();

    if (token == null) {
      throw Exception('Auth token not found.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SalarySlip.fromJson(json)).toList();
      } else {
        print('Failed to load salary slips: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load salary slips: ${response.body}');
      }
    } catch (e) {
      print('Error fetching salary slips: $e');
      throw Exception('Error fetching salary slips: $e');
    }
  }

  Map<String, String> _getHeaders(_authToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  Map<String, String> _getFormHeaders(_authToken) {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Mengambil daftar payslip untuk approval
  Future<List<SalarySlip>> getApprovalGaji() async {
    final String? token = await AppStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/Gaji/getApprovalGaji'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SalarySlip.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Data not found, return empty list
      return [];
    } else {
      throw Exception('Failed to load approval gaji: ${response.statusCode} ${response.body}');
    }
  }
  
  Future<List<SalarySlip>> getGaji() async {
    final String? token = await AppStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/getGaji'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SalarySlip.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Data not found, return empty list
      return [];
    } else {
      throw Exception('Failed to load gaji: ${response.statusCode} ${response.body}');
    }
  }

  // Mengambil detail gaji berdasarkan ID
  Future<SalarySlip> getGajiById(String gajiId) async {
    final String? token = await AppStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/Gaji/getGajiById/$gajiId'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SalarySlip.fromJson(data);
    } else {
      throw Exception('Failed to load gaji detail: ${response.statusCode} ${response.body}');
    }
  }

  // Approve Gaji
  // Future<bool> approveGaji(String gajiId, String? keteranganHrd) async {
  //   final String? token = await AppStorage.getToken();

  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/Gaji/approveGaji/$gajiId'),
  //     headers: _getFormHeaders(token),
  //     body: {'gaji_keterangan_hrd': keteranganHrd ?? ''},
  //   );

  //   if (response.statusCode == 200) {
  //     // response body: {'message': 'Gaji approved successfully'}
  //     return true;
  //   } else {
  //     print('Failed to approve gaji: ${response.statusCode} ${response.body}');
  //     return false;
  //   }
  // }

Future<bool> approveGaji(
    String gajiId, {
    String? keteranganHrd,
    double? gajiPokok,
    double? gajiUangMakan,
    double? gajiPremiHadir,
    double? gajiPotongan,
    double? gajiBpjsKes,
    double? gajiBpjsTk,
    double? bonus,
    double? totalGaji, // Tambahkan totalGaji jika Anda mengirimnya dari frontend
  }) async {
    final Map<String, String> body = {
      'gaji_keterangan_hrd': keteranganHrd ?? '',
      // data gaji yang diperbarui
      if (gajiPokok != null) 'gaji_pokok': gajiPokok.toString(),
      if (gajiUangMakan != null) 'gaji_uang_makan': gajiUangMakan.toString(),
      if (gajiPremiHadir != null) 'gaji_premi_hadir': gajiPremiHadir.toString(),
      if (gajiPotongan != null) 'gaji_potongan': gajiPotongan.toString(),
      if (gajiBpjsKes != null) 'gaji_bpjs_kes': gajiBpjsKes.toString(),
      if (gajiBpjsTk != null) 'gaji_bpjs_tk': gajiBpjsTk.toString(),
      if (bonus != null) 'bonus': bonus.toString(),
      if (totalGaji != null) 'total_gaji': totalGaji.toString(), // Kirim totalGaji yang sudah dihitung
    };
    final String? token = await AppStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/approveGaji/$gajiId'),
      headers: _getFormHeaders(token),
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to approve gaji: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  // Reject Gaji
  Future<bool> rejectGaji(String gajiId, String? keteranganHrd) async {
    final String? token = await AppStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/Gaji/rejectGaji/$gajiId'),
      headers: _getFormHeaders(token), // Menggunakan form-urlencoded
      body: {'gaji_keterangan_hrd': keteranganHrd ?? ''},
    );

    if (response.statusCode == 200) {
      // response body: {'message': 'Gaji rejected successfully'}
      return true;
    } else {
      print('Failed to reject gaji: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}