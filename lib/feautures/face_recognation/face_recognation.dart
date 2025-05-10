import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceScanner(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FaceScanner extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceScanner({super.key, required this.cameras});

  @override
  State<FaceScanner> createState() => _FaceScannerState();
}

class _FaceScannerState extends State<FaceScanner> {
  late CameraController _controller;
  String _result = '';
  bool _checkInSuccess = false;
  bool _scanning = false;
  bool _isFaceDetected = false;

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

  @override
  void initState() {
    super.initState();

    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});

      // Mulai deteksi wajah otomatis setelah kamera siap
      _startFaceDetection();
    });
  }

  void _startFaceDetection() {
    // Mulai deteksi wajah setiap 2 detik
    Future.delayed(Duration(seconds: 2), () async {
      if (_controller.value.isInitialized) {
        // Ambil gambar secara otomatis
        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/captured.jpg';
        await _controller.takePicture().then((XFile file) async {
          final token = await _getFaceToken(File(file.path));
          if (token == null) {
            // Jika wajah tidak terdeteksi, update status
            setState(() {
              _isFaceDetected = false;
              _result = 'Cari wajah...';
            });
          } else {
            // Jika wajah terdeteksi, update status
            setState(() {
              _isFaceDetected = true;
              _result = 'Wajah terdeteksi, silakan Scan!';
            });
          }
          // Panggil ulang deteksi wajah setiap 2 detik
          _startFaceDetection();
        });
      }
    });
  }

  Future<void> _captureAndCheckIn() async {
    setState(() {
      _scanning = true;
      _result = '';
      _checkInSuccess = false;
    });

    final tempDir = await getTemporaryDirectory();
    final imagePath = '${tempDir.path}/captured.jpg';
    await _controller.takePicture().then((XFile file) async {
      final token = await _getFaceToken(File(file.path));
      if (token == null) {
        setState(() {
          _scanning = false;
          _result = 'Wajah tidak terdeteksi.';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('registered_token');
      if (savedToken == null) {
        await prefs.setString('registered_token', token);
        setState(() {
          _scanning = false;
          _result = 'Registrasi wajah berhasil.';
        });
        return;
      }

      final score = await _compareFaces(savedToken, token);
      if (score != null && score > 80) {
        setState(() {
          _scanning = false;
          _checkInSuccess = true;
          _result = 'Check-In Successful\nChecked in at ${TimeOfDay.now().format(context)}';
        });
      } else {
        setState(() {
          _scanning = false;
          _result = 'Wajah tidak dikenali. Score: $score';
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][now.weekday % 7]}, ${now.month} ${now.day}';
    final formattedTime = TimeOfDay.now().format(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _controller.value.isInitialized
            ? Column(
                children: [
                  const SizedBox(height: 20),
                  Text(formattedDate, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                  Text(formattedTime, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Center(
                    child: ClipOval(
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Align your face within the frame', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  _scanning
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _captureAndCheckIn,
                          child: const Text("Scan Wajah"),
                        ),
                  const SizedBox(height: 20),
                  Text(_result, textAlign: TextAlign.center),
                  if (!_isFaceDetected) 
                    const Text('Cari wajah...', style: TextStyle(color: Colors.red, fontSize: 16)),
                  if (_checkInSuccess) ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 50),
                    const SizedBox(height: 10),
                    Text('Check-In Successful', style: TextStyle(color: Colors.green, fontSize: 18)),
                    Text(_result),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: const [
                            Text("Name", style: TextStyle(color: Colors.grey)),
                            Text("Candra Vradita", style: TextStyle(fontSize: 18)),
                            SizedBox(height: 10),
                            Text("Employee ID", style: TextStyle(color: Colors.grey)),
                            Text("EMP1234", style: TextStyle(fontSize: 18)),
                            SizedBox(height: 10),
                            Text("Department", style: TextStyle(color: Colors.grey)),
                            Text("Project", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
