import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app_routes.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/face_recognation/service/face_detection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';

class FaceScannerRegister extends StatefulWidget {
  const FaceScannerRegister({super.key});

  @override
  State<FaceScannerRegister> createState() => _FaceScannerRegisterState();
}

class _FaceScannerRegisterState extends State<FaceScannerRegister> with TickerProviderStateMixin {
  bool _checkInSuccess = false;
  late CameraController _controller;
  bool _isFaceDetected = false;
  String _result = '';
  bool _scanning = false;
  final faceRecoService = FaceDetectionService();
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void dispose() {
    _controller.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Setup pulse animation for the face detection frame
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Set preferred orientations to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI to fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera, 
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    try {
      await _controller.initialize();
      // Ensure the camera isn't mirrored for the preview
      await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      if (!mounted) return;

      setState(() {});
      _startFaceDetection();
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error initializing camera: $e';
        });
      }
    }
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

  void _startFaceDetection() {
    if (!mounted) return;
    
    Future.delayed(Duration(seconds: 2), () async {
      if (!mounted) return;
      if (_controller.value.isInitialized) {
        try {
          final tempDir = await getTemporaryDirectory();
          final imagePath = '${tempDir.path}/captured.jpg';
          await _controller.takePicture().then((XFile file) async {
            if (!mounted) return;
            final token = await _getFaceToken(File(file.path));
            if (token == null) {
              setState(() {
                _isFaceDetected = false;
                _result = 'Searching for face...';
              });
            } else {
              setState(() {
                _isFaceDetected = true;
                _result = 'Face detected, please register!';
              });
            }
            if (mounted) _startFaceDetection();
          });
        } catch (e) {
          if (mounted) {
            setState(() {
              _result = 'Error: ${e.toString()}';
              _isFaceDetected = false;
            });
            _startFaceDetection();
          }
        }
      }
    });
  }

  Future<void> _registerFace() async {
    setState(() {
      _scanning = true;
      _result = '';
    });

    try {
      final XFile picture = await _controller.takePicture();
      
      final token = await _getFaceToken(File(picture.path));
      if (token == null) {
        setState(() {
          _scanning = false;
          _result = 'Face not detected.';
        });
        return;
      }

      final userData = await AppStorage.getUser();
      final userId = userData?['user_id'];
      
      try {
        await faceRecoService.saveUserFaceToken(userId, token);
        
        // Show success dialog
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Success', 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                )
              ),
              content: const Text(
                'Face registration successful!',
                style: TextStyle(color: Colors.white)
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK', 
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to home page or desired screen
                    Navigator.of(context).pushReplacementNamed(AppRoutes.appRoot);
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          _scanning = false;
          _result = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _scanning = false;
        _result = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][now.weekday % 7]}, ${now.month} ${now.day}';
    final formattedTime = TimeOfDay.now().format(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen camera preview
          _controller.value.isInitialized
              ?  SizedBox.expand(
  child: FittedBox(
    fit: BoxFit.cover,
    child: Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(
        // Putar sumbu Y 180 derajat (pi radian) untuk flip horizontal
        // HANYA jika kamera depan.
        // Anda perlu memiliki logika untuk mengetahui _isFrontCamera
        // Jika _isFrontCamera true, maka lakukan flip.
        3.14159, // pi radian untuk 180 derajat
      ),
      child: SizedBox(
        // Ini adalah cara untuk mengatasi orientasi landscape/portrait dari preview
        // Terkadang previewSize bisa berbeda orientasinya dari layar.
        // Anda perlu memastikan _controller.value.previewSize tidak null.
        width: _controller.value.previewSize!.height,
        height: _controller.value.previewSize!.width,
        child: CameraPreview(_controller),
      ),
    ),
  ),
)
              : Container(
                  color: Colors.black,
                  width: screenSize.width,
                  height: screenSize.height,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
          
          // Semi-transparent overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // UI Elements
          SafeArea(
            child: Column(
              children: [
                // Top section with date and time
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 30, 
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Spacer to push content to bottom
                const Spacer(),
                
                // Face detection frame with animation
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isFaceDetected ? Colors.greenAccent : Colors.white60,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _isFaceDetected ? Icons.check_circle_outline : Icons.face,
                              color: _isFaceDetected ? Colors.greenAccent : Colors.white60,
                              size: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const Spacer(),
                
                // Bottom section with status and button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      // Status text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _result.isNotEmpty ? _result : _isFaceDetected 
                              ? 'Face detected, please register!' 
                              : 'Align your face within the circle',
                          style: TextStyle(
                            color: _isFaceDetected ? Colors.greenAccent : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      // Register button
                      _scanning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton(
                              onPressed: _isFaceDetected ? _registerFace : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFaceDetected ? Colors.greenAccent : Colors.grey.withOpacity(0.3),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: _isFaceDetected ? 8 : 0,
                              ),
                              child: const Text(
                                "Register Face",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}