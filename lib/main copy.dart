// Gabungan antara sistem face recognition dan tampilan UI stylish sebelumnya\
// Menggunakan Face++ API dan tampilan bundar kamera dengan status check-in

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Check-In',
      debugShowCheckedModeBanner: false,
      home: const FaceCheckInPage(),
    );
  }
}

class FaceCheckInPage extends StatefulWidget {
  const FaceCheckInPage({super.key});
  @override
  State<FaceCheckInPage> createState() => _FaceCheckInPageState();
}

class _FaceCheckInPageState extends State<FaceCheckInPage> {
  File? _image;
  String _status = 'Align your face within the frame';
  bool _isFaceDetected = false;
  bool _isRegistered = false;
  bool _checking = false;

  Future<void> _pickAndDetectFace({required bool isRegister}) async {
    setState(() => _checking = true);

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    final imageFile = File(picked.path);
    setState(() => _image = imageFile);

    final token = await _getFaceToken(imageFile);
    if (token == null) {
      setState(() {
        _status = 'Wajah tidak terdeteksi.';
        _checking = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (isRegister) {
      await prefs.setString('registered_token', token);
      setState(() {
        _isRegistered = true;
        _status = 'Registrasi berhasil!';
        _checking = false;
      });
    } else {
      final savedToken = prefs.getString('registered_token');
      if (savedToken == null) {
        setState(() {
          _status = 'Belum ada data wajah yang didaftarkan.';
          _checking = false;
        });
        return;
      }

      final score = await _compareFaces(savedToken, token);
      if (score != null && score > 80) {
        setState(() {
          _status = 'Check-In Successful! Score: $score';
          _isFaceDetected = true;
        });
      } else {
        setState(() => _status = 'Login gagal. Score: $score');
      }
      setState(() => _checking = false);
    }
  }

  Future<String?> _getFaceToken(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;
    final resizedImage = img.copyResize(image, width: 600);
    final jpg = img.encodeJpg(resizedImage, quality: 85);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/resized.jpg');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Check-In'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text("Wednesday, May 7", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("06:00 PM", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
                Text(_status, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: ClipOval(
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 120, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                if (_checking) const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickAndDetectFace(isRegister: true),
                      child: const Text('Daftar Wajah'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _pickAndDetectFace(isRegister: false),
                      child: const Text('Check-In'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isFaceDetected)
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      const Text("Checked in at 06:00 PM"),
                      const SizedBox(height: 12),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: Candra Vradita"),
                              Text("Employee ID: EMP1234"),
                              Text("Department: Project"),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
