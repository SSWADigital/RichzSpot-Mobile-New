import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';

class AuthService {

  Future<bool> refreshToken() async {
  // final prefs = await SharedPreferences.getInstance();
  final refreshToken = AppStorage.getRefreshToken();

  final response = await http.post(
    Uri.parse('${App.apiBaseUrl}Auth/refresh_token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh_token': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await AppStorage.saveTokens(data['token'], data['refresh_token']);
    return true;
  } else {
    return false;
  }
}

  
   Future<Map<String, dynamic>> login(String email, String password, String? fcmToken, String? platform) async {
    final url = Uri.parse('${App.authBaseUrl}/auth/login');

    Map<String, String> body = {'username': email, 'password': password};
    if (fcmToken != null) {
      body['fcm_token'] = fcmToken;
    }
    if (platform != null) {
      body['platform'] = platform;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return data;
      } else {
        print(response.body);
        return {'status': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'status': false, 'message': 'Error occurred'};
    }
  }

}