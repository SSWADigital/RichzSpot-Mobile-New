import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class FaceDetectionService {
  static const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
  static const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
  static const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
  static const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';

  Future<String?> _getFaceToken(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;
    
    final resizedImage = img.copyResize(image, width: 600);
    final jpg = img.encodeJpg(resizedImage, quality: 85);
    final tempFile = File('${(await getTemporaryDirectory()).path}/resized.jpg');
    await tempFile.writeAsBytes(jpg);

    final request = http.MultipartRequest('POST', Uri.parse(detectUrl));
    request.fields['api_key'] = apiKey;
    request.fields['api_secret'] = apiSecret;
    request.files.add(await http.MultipartFile.fromPath('image_file', tempFile.path));
    
    final response = await request.send();
    final result = await http.Response.fromStream(response);
    final data = json.decode(result.body);

    if (result.statusCode == 200 && (data['faces'] as List).isNotEmpty) {
      return data['faces'][0]['face_token'];
    }
    return null;
  }

  Future<double?> _compareFaces(String token1, String token2) async {
    final response = await http.post(
      Uri.parse(compareUrl),
      body: {
        'api_key': apiKey,
        'api_secret': apiSecret,
        'face_token1': token1,
        'face_token2': token2,
      },
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data.containsKey('confidence')) {
      return data['confidence'].toDouble();
    }
    return null;
  }

  Future<bool> captureAndCheckIn(CameraController controller) async {
    try {
      final xFile = await controller.takePicture();
      final file = File(xFile.path);
      
      final token = await _getFaceToken(file);
      if (token == null) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('registered_token');
      
      if (savedToken == null) {
        await prefs.setString('registered_token', token);
        return true;
      }

      final score = await _compareFaces(savedToken, token);
      return score != null && score > 80;
    } catch (e) {
      return false;
    }
  }

  Future<bool> detectFace(CameraController controller) async {
    try {
      final xFile = await controller.takePicture();
      final file = File(xFile.path);
      
      final token = await _getFaceToken(file);
      return token != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveUserFaceToken(String userId, String faceToken) async {
      print("Data Face Last: $userId, $faceToken");
    // try {
  try {
      final url = Uri.parse('${App.authBaseUrl}/auth/save_user_token');
      final token = AppStorage.getToken();
final response = await http.post(
  url,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'user_id': userId,
    'face_token': faceToken,
  }),
);

      final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // return data; // ✅ return Map
      return true;
    } else {
      return false;
      // return {'status': false, 'message': 'Invalid credentials'};
    }

    } catch (e) {
      print("Error Face: $e");
      return false;
    }
  }

    Future<String> getFaceToken(String userId, String faceToken) async {
      print("Data Face Last: $userId, $faceToken");
    // try {
  try {
      final url = Uri.parse('${App.authBaseUrl}/auth/get_user_face_token');
      final token = AppStorage.getToken();
final response = await http.post(
  url,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'user_id': userId,
  }),
);

      final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // return data; // ✅ return Map
      return data['face_token'];
    } else {
      return "false";
      // return {'status': false, 'message': 'Invalid credentials'};
    }

    } catch (e) {
      print("Error Face: $e");
      return "false";
    }
  }


}