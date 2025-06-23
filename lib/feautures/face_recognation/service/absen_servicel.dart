import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/auth/services/auth_service.dart';

class AbsenService {
  // Future<AbsenResponse> cekAbsen() async {
  //   final token = await AppStorage.getToken();
  //   final user = await AppStorage.getUser();
  //   final userId = user?['user_id']; // Use the provided userId or fallback to the stored one
  //   if (userId == null) {
  //     throw Exception('User ID is required');
  //   }
  //   final url = Uri.parse('${App.apiBaseUrl}Absen/cekAbsen/$userId');
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   };

  //   try {
  //     final response = await http.get(url, headers: headers);
  //     // print("Cek Absen: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       return AbsenResponse.fromJsonCekAbsen(data);
  //     } else if (response.statusCode == 401) {
  //       // refresh token logic can be added here if needed
  //       AuthService authService = AuthService();
  //       final isRefreshed = await authService.refreshToken();
  //       if (isRefreshed) {
  //         // Retry the request after refreshing the token
  //         return cekAbsen();
  //       }
  //       // throw Exception('Unauthorized');
  //     } else {
  //       throw Exception('Failed to load attendance data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to connect to the server: $e');
  //   }
  // }

   Future<AbsenResponse> cekAbsen() async {
    final token = await AppStorage.getToken();
    final user = await AppStorage.getUser();
    final userId = user?['user_id']; // Use the provided userId or fallback to the stored one
    if (userId == null) {
      throw Exception('User ID is required');
    }
    final url = Uri.parse('${App.apiBaseUrl}Absen/cekAbsen/$userId');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      // print("Cek Absen: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AbsenResponse.fromJsonCekAbsen(data);
      } else if (response.statusCode == 401) {
        // refresh token logic can be added here if needed
        AuthService authService = AuthService();
        final isRefreshed = await authService.refreshToken();
        if (isRefreshed) {
          // Retry the request after refreshing the token
          return cekAbsen();
        }
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load attendance data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<AbsenResponse> absenCheckIn({
    required String userId,
    String? checkInLokasi,
  }) async {
    final token = await AppStorage.getToken();
    final url = Uri.parse('${App.apiBaseUrl}Absen/absenCheckIn');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'id': userId.toString(),
      if (checkInLokasi != null) 'absen_checkin_lokasi': checkInLokasi,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AbsenResponse.fromJsonAction(data);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Check-in failed with status code: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Check-in failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform check-in: $e');
    }
  }

  Future<AbsenResponse> absenCheckOut({
    required String absenId,
    String? checkOutLokasi,
  }) async {
    final token = await AppStorage.getToken();
    final url = Uri.parse('${App.apiBaseUrl}Absen/absenCheckOut');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = {
      'id': absenId,
      if (checkOutLokasi != null) 'absen_checkout_lokasi': checkOutLokasi,
    };

      final response = await http.post(url, headers: headers, body: body);

      print("Check Out: ${response.body}");
    try {

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AbsenResponse.fromJsonAction(data);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Check-out failed with status code: ${response.statusCode}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Check-out failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

}

class AbsenResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;
  final String? absenId;
  final String? checkin;
  final String? checkout;
  final String? faceToken;

  AbsenResponse({
    required this.status,
    required this.message,
    this.data,
    this.absenId,
    this.checkin,
    this.checkout,
    this.faceToken,
  });

  factory AbsenResponse.fromJsonCekAbsen(Map<String, dynamic> json) {
    return AbsenResponse(
      status: true,
      message: 'Success',
      absenId: json['absen_id'] ?? '-',
      checkin: json['checkin'] ?? '-',
      checkout: json['checkout'] ?? '-',
      faceToken: json['face_token'] ?? '-',
      data: json,
    );
  }

  factory AbsenResponse.fromJsonAction(Map<String, dynamic> json) {
    return AbsenResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // You can add methods to easily check the status from cekAbsen
  bool get isNotCheckedInOrOut => absenId == '-';
  bool get isCheckedIn => checkin != '-' && checkout == '-';
  bool get isCheckedOut => checkin != '-' && checkout != '-';
  // Note: The 'previous_day_not_checkout' logic was server-side,
  // if you need it here, you'd have to handle it based on the 'data'
  // or potentially a different API response.
}