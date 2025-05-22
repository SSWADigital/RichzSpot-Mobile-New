import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:richzspot/feautures/face_recognation/models/user_model.dart';
import 'package:richzspot/feautures/face_recognation/widgets/camera_preview_widget.dart';
import 'package:richzspot/feautures/face_recognation/service/face_detection_service.dart';
import 'package:richzspot/feautures/face_recognation/widgets/success_check_in_widget.dart';
class FaceScannerScreen extends StatefulWidget {
  const FaceScannerScreen({super.key});

  @override
  State<FaceScannerScreen> createState() => _FaceScannerScreenState();
}

class _FaceScannerScreenState extends State<FaceScannerScreen> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _scanning = false;
  bool _checkInSuccess = false;
  String _statusMessage = 'Align your face within the frame';
  final FaceDetectionService _faceService = FaceDetectionService();
  final UserModel _userModel = UserModel(
    name: 'Candra Vradita',
    employeeId: 'EMP1234',
    department: 'Project',
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Align your face within the frame';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Camera initialization failed';
      });
    }
  }

  void _startScanning() async {
    if (_scanning || _checkInSuccess) return;

    setState(() {
      _scanning = true;
      _statusMessage = 'Scanning...';
    });

    try {
      await _faceService.captureAndCheckIn(_controller);
      
      // Simulate successful check-in after scanning
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _scanning = false;
        _checkInSuccess = true;
      });
    } catch (e) {
      setState(() {
        _scanning = false;
        _statusMessage = 'Scan failed. Please try again.';
      });
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _getFormattedTime() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute PM';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Date and time header
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Text(
                    _getFormattedDate(),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    _getFormattedTime(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isInitialized
                  ? _checkInSuccess
                      ? SuccessCheckInWidget(
                          checkInTime: _getFormattedTime(),
                          user: _userModel,
                        )
                      : CameraPreviewWidget(
                          controller: _controller,
                          scanning: _scanning,
                          statusMessage: _statusMessage,
                          onScanPressed: _startScanning,
                        )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            
            // Bottom navigation
            // const BottomNavigationWidget(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}