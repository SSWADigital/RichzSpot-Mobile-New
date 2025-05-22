import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:richzspot/core/constant/app.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/face_recognation/service/absen_servicel.dart';
import 'package:richzspot/feautures/face_recognation/service/face_detection_service.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

// API Constants - Keep these the same
const String apiKey = '9IpazE02mIRTEESsqvNg4Dk3gt9pBVDq';
const String apiSecret = 'HfXHFW3HSDV8hmtTJ1zyN6i9bcziwtrG';
const String detectUrl = 'https://api-us.faceplusplus.com/facepp/v3/detect';
const String compareUrl = 'https://api-us.faceplusplus.com/facepp/v3/compare';
const double confidenceThreshold = 80.0;

class FaceScanner extends StatefulWidget {
  const FaceScanner({super.key});

  @override
  State<FaceScanner> createState() => _FaceScannerState();
}

class _FaceScannerState extends State<FaceScanner> with TickerProviderStateMixin {
  // State variables - keeping all the original ones
  bool _isCheckedIn = false;
  bool _isCheckingOut = false;
  late CameraController _controller;
  bool _isFaceDetected = false;
  String _result = 'Ready for Check-In/Out';
  bool _scanning = false;
  final AbsenService _absenService = AbsenService();
  bool _isCameraInitializing = true;
  var userData;
  Size? _previewSize;
  late CameraDescription _cameraDescription;
  
  // New animation controllers
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  
  // UI customization variables
  final Color _primaryColor = AppColors.lightBlue;
  final Color _accentColor = AppColors.lightBlue;
  final Color _successColor = AppColors.successGreen;
  final Color _errorColor = AppColors.error;
  final Color _surfaceColor = Colors.grey.withOpacity(0.7);
  
  @override
  void dispose() {
    _controller.dispose();
    _pulseAnimationController.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    // Set preferred device orientation for better UX
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Initialize animations
    _setupAnimations();
    
    // Initialize camera and load user data
    _loadUserData();
  }
  
  void _setupAnimations() {
    // Pulse animation for face circle
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Scanning animation
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.linear,
      ),
    );
  }

  Future<void> _loadUserData() async {
    final data = await AppStorage.getUser();
    if (mounted) {
      setState(() {
        userData = data;
        // print("User Data: $userData");
      });
      print("User Data Face Token: ${userData?['face_token']}");
      _checkTodayAttendance(); // Check attendance on screen load
    _initializeCamera();

    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
    });

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraDescription = frontCamera;

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off);
      
      // For correct aspect ratio
      _previewSize = Size(
        _controller.value.previewSize!.height,
        _controller.value.previewSize!.width,
      );

      if (!mounted) return;

      setState(() {
        _isCameraInitializing = false;
      });

      _startFaceDetection();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
          _result = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  // Keep all the original API and detection functions unchanged
  Future<String?> _detectFaceGetToken(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    final resizedImage = img.copyResize(image, width: 600);
    final jpg = img.encodeJpg(resizedImage, quality: 85);
    final tempFile = File('${(await getTemporaryDirectory()).path}/detected_face.jpg');
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
    } else {
      debugPrint('Face++ API Error (Detect): ${result.body}');
    }
    return null;
  }

  Future<double?> _compareFaces(String? faceToken1, String? faceToken2) async {
    if (faceToken1 == null || faceToken2 == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse(compareUrl),
      body: {
        'api_key': apiKey,
        'api_secret': apiSecret,
        'face_token1': faceToken1,
        'face_token2': faceToken2,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['confidence'] != null) {
        return data['confidence'] as double;
      }
    } else {
      // print("Face++ Face Token 1: $faceToken1");
      // print("Face++ Face Token 2: $faceToken2");
      // print("Response Request: ${response.request}");
      // debugPrint('Face++ API Error (Compare): ${response.body}');
    }
    return null;
  }

  void _startFaceDetection() {
    if (!mounted) return;
    
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      if (_controller.value.isInitialized && !_scanning) {
        try {
          final XFile file = await _controller.takePicture();
          final currentFaceToken = await _detectFaceGetToken(File(file.path));
          final faceToken = await AppStorage.getFaceToken();

          if (currentFaceToken != null && faceToken != null) {
            final confidence = await _compareFaces(currentFaceToken, faceToken);
            if (confidence != null && confidence >= confidenceThreshold) {
              if (mounted) {
                setState(() {
                  _isFaceDetected = true;
                  if (!_isCheckedIn && !_isCheckingOut) {
                    _processCheckIn();
                  } else if (_isCheckingOut) {
                    _processCheckOut();
                  }
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  _isFaceDetected = false;
                  _result = 'Face doesn\'t match, please try again';
                });
              }
            }
          } else {
            if (mounted) {
              setState(() {
                _isFaceDetected = false;
                _result = currentFaceToken == null ? 'No face detected' : 'User face data unavailable';
              });
            }
          }
        } catch (e) {
          debugPrint('Error during face detection: $e');
          if (mounted) {
            setState(() {
              _isFaceDetected = false;
              _result = 'Error detecting face';
            });
          }
        } finally {
          if (mounted && !_scanning) {
            _startFaceDetection();
          }
        }
      }
    });
  }

  Future<void> _checkTodayAttendance() async {
    if (userData == null || userData['user_id'] == null || !mounted) return;

    setState(() {
      _scanning = true;
      _result = 'Checking Attendance...';
    });

    try {
      final response = await _absenService.cekAbsen();
      if (mounted) {
        if (response.status) {
          setState(() {
            _isCheckedIn = response.isCheckedIn;
            _isCheckingOut = response.isCheckedOut;
            if (_isCheckedIn && !_isCheckingOut) {
              _result = 'Ready for Check-Out';
            } else if (_isCheckedIn && _isCheckingOut) {
              _result = 'Checked-Out Today';
            } else {
              _result = 'Ready for Check-In';
            }
          });
        } else {
          setState(() {
            _result = 'Failed to check attendance';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error checking attendance';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _scanning = false;
        });
      }
    }
  }

  Future<void> _processCheckIn() async {
    if (_scanning || _isCheckedIn || userData == null || userData['user_id'] == null) return;

    setState(() {
      _scanning = true;
      _result = 'Processing Check-In...';
    });

    try {
      final response = await _absenService.absenCheckIn(userId: userData['user_id']);
      if (mounted) {
        if (response.status) {
          setState(() {
            _isCheckedIn = true;
            _isCheckingOut = false;
            _scanning = false;
            _result = 'Ready for Check-Out';
          });
          _showSuccessDialog('Check-In Successful', true);
        } else {
          setState(() {
            _scanning = false;
            _result = 'Check-In failed: ${response.message}';
          });
          _showErrorDialog('Check-In Failed', response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _result = 'Error during Check-In: $e';
        });
        _showErrorDialog('Check-In Error', e.toString());
      }
    }
  }

  Future<void> _processCheckOut() async {
    // if (_scanning || !_isCheckedIn || _isCheckingOut || userData == null) return;
    final cekAbsen = await _absenService.cekAbsen();

    final absenId = cekAbsen.absenId;

    // print("Absen ID: $absenId");

    setState(() {
      _scanning = true;
      _result = 'Processing Check-Out...';
    });

    try {
      final currentAbsenId = absenId;
      if (currentAbsenId == null) {
        setState(() {
          _scanning = false;
          _result = 'Cannot find attendance ID for Check-Out';
        });
        _showErrorDialog('Check-Out Failed', 'Attendance ID not found');
        return;
      }

      final response = await _absenService.absenCheckOut(absenId: currentAbsenId);
      print("CheckOut: ${response.message}");
      if (mounted) {
        if (response.status) {
          setState(() {
            _isCheckedIn = false;
            _isCheckingOut = true;
            _scanning = false;
            _result = 'Checked-Out Today';
          });
          _showSuccessDialog('Check-Out Successful', false);
        } else {
          setState(() {
            _scanning = false;
            _result = 'Check-Out failed: ${response.message}';
          });
          _showErrorDialog('Check-Out Failed', response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _result = 'Error during Check-Out: $e';
        });
        _showErrorDialog('Check-Out Error', e.toString());
      }
    }
  }

  // Redesigned success dialog with futuristic UI
  void _showSuccessDialog(String title, bool isCheckIn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _successColor.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: _successColor,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Title with slide animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 50, end: 0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: 1 - value / 50,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // User greeting
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  children: [
                    const TextSpan(text: "Hello, "),
                    TextSpan(
                      text: "${userData?['user_nama_lengkap'] ?? 'User'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Time display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                      color: _primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm:ss').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // OK button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: _primaryColor.withOpacity(0.5),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Redesigned error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: _errorColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(color: _errorColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.blueGrey.shade900],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Loading",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final now = DateTime.now();
    final formattedDate = '${['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][now.weekday % 7]}, ${DateFormat('MMMM d').format(now)}';
    final formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview that fills the screen without mirroring
          if (!_isCameraInitializing)
            SizedBox.expand(
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
),
            
          // Dark overlay for better UI visibility
          Container(
            color: Colors.black.withOpacity(0.25),
          ),
          
          // Main UI content
          SafeArea(
            child: Column(
              children: [
                // Top info bar with date and time
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: _isFaceDetected ? _successColor : _primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isFaceDetected ? _successColor : _primaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isFaceDetected ? "Face Detected" : "Scanning",
                              style: TextStyle(
                                color: _isFaceDetected ? _successColor : _primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Face detection area
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated scanning UI
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: screenSize.width * 0.65,
                                height: screenSize.width * 0.65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isFaceDetected 
                                      ? _successColor.withOpacity(0.7) 
                                      : _primaryColor.withOpacity(0.7),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                        
                        // Inner face guide
                        Container(
                          width: screenSize.width * 0.5,
                          height: screenSize.width * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isFaceDetected 
                                ? _successColor.withOpacity(0.3) 
                                : _primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        
                        // Face icon
                        Icon(
                          Icons.face,
                          size: screenSize.width * 0.25,
                          color: _isFaceDetected 
                            ? _successColor.withOpacity(0.3) 
                            : Colors.white.withOpacity(0.25),
                        ),
                        
                        // Scanning effect
                        if (_scanning && !_isFaceDetected)
                          AnimatedBuilder(
                            animation: _scanAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: _scanAnimation.value * screenSize.width * 0.65,
                                child: Container(
                                  width: screenSize.width * 0.65,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        _primaryColor,
                                        _accentColor,
                                        _primaryColor,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom UI panel
              Container(
  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
  decoration: BoxDecoration(
    color: Colors.white, // Latar belakang panel bawah menjadi putih
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // Shadow lebih lembut, sesuai tema cerah
        blurRadius: 10,
        offset: const Offset(0, -3),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Status message
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          // Latar belakang status message: biru muda transparan jika scanning, hijau muda transparan jika sukses
          color: _isFaceDetected ? _successColor.withOpacity(0.1) : _primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _isFaceDetected ? Icons.check_circle_outline : Icons.info_outline,
              // Warna ikon: hijau jika sukses, biru jika scanning
              color: _isFaceDetected ? _successColor : _primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _result,
                style: TextStyle(
                  // Warna teks: hijau jika sukses, hitam jika scanning (sesuai tema putih/hitam)
                  color: _isFaceDetected ? _successColor : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      // Action buttons
      // if (!_isCheckedIn && !_isCheckingOut) // Tombol CHECK IN (dikomentari)
      //   _buildActionButton(
      //     label: "CHECK IN",
      //     icon: Icons.login_rounded,
      //     color: _primaryColor, // Warna tombol check-in: biru
      //     onPressed: () {
      //       setState(() {
      //         _result = 'Scanning face for Check-In...';
      //         _scanning = true;
      //       });
      //     },
      //   ),

      if (_isCheckedIn && !_isCheckingOut && _isFaceDetected) // Tombol CHECK OUT
        _buildActionButton(
          label: "CHECK OUT",
          icon: Icons.logout_rounded,
          color: _primaryColor, // Warna tombol checkout menjadi biru (sesuai gambar)
          onPressed: () {
            setState(() {
              _isCheckingOut = true;
              _result = 'Scanning face for Check-Out...';
              _scanning = true;
              // _processCheckOut();
            });
          },
        ),

      const SizedBox(height: 12),

      // Helper text
      Text(
        _scanning
          ? "Please keep your face within the circle"
          : "Position your face within the circle",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textGray, // Warna teks abu-abu sekunder karena latar belakang putih
          fontSize: 12,
        ),
      ),
    ],
  ),
),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isCameraInitializing || _scanning)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: _accentColor,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isCameraInitializing ? "Initializing Camera..." : "Processing...",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
                          required String label,
                          required IconData icon,
                          required Color color,
                          required VoidCallback onPressed,
                        }) {
                          return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(icon, color: Colors.white),
                            label: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            ),
                            style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            ),
                            onPressed: onPressed,
                          ),
                          );
                        }
}