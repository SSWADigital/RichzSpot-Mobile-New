import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class OvertimeService {

   static Future<http.Response> submitOvertimeRequest({
  required String date,
  required String? type,
  required String hoursStart,
  required String hoursEnd,
  required String reason,
}) async {
  final url = Uri.parse('${App.apiBaseUrl}lembur/addData');

  // ✅ Await token yang bertipe Future<String?>
  final String? token = await AppStorage.getToken();

  final body = jsonEncode({
    'lembur_tgl': date,
    'lembur_jam_mulai': hoursStart,
    'lembur_jam_selesai': hoursEnd,
    'id_jenis_lembur': type,
    'lembur_keterangan': reason,
  });

  final headers = {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  final response = await http.post(url, headers: headers, body: body);

  return response;
}

  static Future<List<Map<String, dynamic>>> getOvertimeTypes() async {
    final url = Uri.parse('${App.apiBaseUrl}Lembur/jenislembur');
    final String? token = await AppStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    // print("Overtime: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load overtime types');
    }
  }

  static Future<List<Map<String, dynamic>>> getOvertimeRequestsByUserId(String userId) async {
  final url = Uri.parse('${App.apiBaseUrl}Lembur/lemburr?id_user=$userId');
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
    throw Exception('Failed to load overtime data');
  }
}


}