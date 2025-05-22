// lib/feautures/payslip/services/salary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart'; // Make sure App.apiBaseUrl is defined here
import 'package:richzspot/core/storage/app_storage.dart'; // To get the token
import '../models/salary_slip.dart';

class SalaryService {
  static const String _baseUrl = App.apiBaseUrl; // Use your base URL

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
}