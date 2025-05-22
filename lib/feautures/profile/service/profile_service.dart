import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Untuk MediaType
import 'dart:io';

import 'package:richzspot/core/constant/app.dart'; // Untuk File

class ProfileService {
  // static const String _baseUrl = '/'; // GANTI DENGAN URL API CI3 Anda

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData, File? imageFile) async {
    final url = Uri.parse('${App.apiBaseUrl}User/update_profile');

    var request = http.MultipartRequest('POST', url);

    // Tambahkan field data
    userData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Tambahkan file gambar jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'user_foto', // Nama field di API CI3 Anda
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // Atau 'png'
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${App.apiBaseUrl}User/change_password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
    }
  }

  // Anda bisa menambahkan method lain di sini untuk login, register, dll.
  // Contoh untuk mengambil data user jika diperlukan
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final url = Uri.parse('${App.apiBaseUrl}User/get_user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'status': 'error', 'message': 'Server error: ${response.statusCode}'};
    }
  }
}