import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/face_recognation/service/face_detection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';

class FaceScanner extends StatefulWidget {
  const FaceScanner({super.key});

  // final List<CameraDescription> cameras;

  @override
  State<FaceScanner> createState() => _FaceScannerState();
}

class _FaceScannerState extends State<FaceScanner> {
  bool _checkInSuccess = false;
  late CameraController _controller;
  bool _isFaceDetected = false;
  String _result = '';
  bool _scanning = false;
  final faceRecoService = FaceDetectionService();
  bool _isCameraInitializing = true;
  var userData2;
  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getUserData();
  //   final frontCamera = cameras.firstWhere(
  //     (camera) => camera.lensDirection == CameraLensDirection.front,
  //     orElse: () => cameras.first,
  //   );

  //   _controller = CameraController(frontCamera, ResolutionPreset.medium);
  //   _controller.initialize().then((_) {
  //     if (!mounted) return;
  //     setState(() {});

  //     // Mulai deteksi wajah otomatis setelah kamera siap
  //     _startFaceDetection();
  //   });
  // }
  }

Future<void> _initializeCamera() async {
  setState(() {
  _isCameraInitializing = false;
});

  final cameras = await availableCameras();

  final frontCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first,
  );

  _controller = CameraController(frontCamera, ResolutionPreset.medium);
  await _controller.initialize();

  if (!mounted) return;

  setState(() {});
  _isCameraInitializing = false;
  _startFaceDetection();
}

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
              _captureAndCheckIn();
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

      final userData = await AppStorage.getUser();
      print("userData: $userData");
      final userId = userData?['user_id'];
      try {
        final faceInsert =  await faceRecoService.saveUserFaceToken(userId, token);
        print("Face Insert: $faceInsert");
      } catch (e) {
        print("Error Woy: $e");
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
      showDialog(
  context: context,
  builder: (_) => Dialog( // Use Dialog instead of AlertDialog for more customization
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // More rounded corners
    elevation: 8, // Add shadow for depth
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32), // Larger icon
              const SizedBox(width: 12),
              Text(
                'Check-In Berhasil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Larger, bold title
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText( // Use RichText for better text formatting
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16), // Inherit default style and increase size
              children: [
                const TextSpan(text: "Halo, ", style: TextStyle(fontWeight: FontWeight.w500)), // Semi-bold
                TextSpan(text: "${userData2['user_nama_lengkap']}", style: const TextStyle(fontWeight: FontWeight.bold)), // Bold name
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              children: [
                const TextSpan(text: "Waktu Check-In: ", style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: TimeOfDay.now().format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              children: [
                const TextSpan(text: "Departemen: ", style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: "${userData2['departemen_nama']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton( // Use ElevatedButton for a more modern button style
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Increased padding
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded button
              backgroundColor: Colors.blue, // Example color
              foregroundColor: Colors.white,
            ),
            child: const Text('OK', style: TextStyle(fontSize: 18)), // Larger text
          ),
        ],
      ),
    ),
  ),
);

      } else {
        setState(() {
          _scanning = false;
          _result = 'Wajah tidak dikenali. Score: $score';
        });
      }
    });
  }


  Future<void> getUserData() async {
  final data = await AppStorage.getUser();
  setState(() {
    userData2 = data;
  });
}

@override
Widget build(BuildContext context) {
  final now = DateTime.now();
  final formattedDate = '${['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][now.weekday % 7]}, ${now.month} ${now.day}';
  final formattedTime = TimeOfDay.now().format(context);

  if (userData2 == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
          color: Colors.blueAccent,
        )),
      );
    }

  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: _isCameraInitializing
          ? const Center(child: CircularProgressIndicator())
          : _controller.value.isInitialized
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
                        : const SizedBox(),
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
                            children: [
                              Text("Name", style: TextStyle(color: Colors.grey)),
                              Text("${userData2['user_nama_lengkap']}", style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Text("Employee ID", style: TextStyle(color: Colors.grey)),
                              Text("${userData2['kode_pegawai'] ?? '-'}", style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Text("Department", style: TextStyle(color: Colors.grey)),
                              Text("${userData2['departemen_nama']}", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              : const Center(child: CircularProgressIndicator(
                color: Colors.blueAccent,
              )),
    ),
  );
}

}
