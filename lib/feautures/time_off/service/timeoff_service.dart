import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class TimeOffService {



  static Future<List<Map<String, dynamic>>> getTimeOffTypes() async {
    final String? token = await AppStorage.getToken();
    final user = await AppStorage.getUser();

    final url = Uri.parse('${App.apiBaseUrl}Cuti/jenisCuti/${user?['departemen_id']}');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    print("TimeOff: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load TimeOff types');
    }
  }

  static Future<List<Map<String, dynamic>>> getTimeOffRequestsByUserId(String userId) async {
  final url = Uri.parse('${App.apiBaseUrl}Cuti/Cuti?id_user=$userId');
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
    
    throw Exception('Failed to load TimeOff data');
  }
}


}