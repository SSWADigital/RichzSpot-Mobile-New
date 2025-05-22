import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class AttendanceService {
  static Future<List<Map<String, dynamic>>> getAttendanceHistory(
    String userId,
    int page,
    int limit,
  ) async {
    final url = Uri.parse('${App.apiBaseUrl}absen/absenByUserId/$userId?page=$page&limit=$limit');
    final String? token = await AppStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load attendance history');
    }
  }

}