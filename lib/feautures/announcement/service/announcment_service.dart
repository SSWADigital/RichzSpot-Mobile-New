import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class AnnouncementService {
  static Future<List<Map<String, dynamic>>> getAnnouncementsByDepartment(String idDep) async {
    final url = Uri.parse('${App.apiBaseUrl}Pengumuman/getByIdDep/$idDep');
    final String? token = await AppStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    // print("Announcement: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load announcements for department $idDep');
    }
  }
}