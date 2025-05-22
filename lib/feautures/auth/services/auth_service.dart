import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';

class AuthService {
  
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