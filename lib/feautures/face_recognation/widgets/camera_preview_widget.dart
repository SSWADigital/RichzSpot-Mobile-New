import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final bool scanning;
  final String statusMessage;
  final VoidCallback onScanPressed;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.scanning,
    required this.statusMessage,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Face scanning circle
        Stack(
          alignment: Alignment.center,
          children: [
            // Camera circle border
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            
            // Dashed inner circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            
            // Center focus indicators
            Icon(
              Icons.crop_free,
              size: 40,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Status text
        Text(
          statusMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 30),
        
        // Scanning indicator or scan button
        if (scanning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 4,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Scanning...',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          )
        else
          GestureDetector(
  onTap: onScanPressed, // Ganti dengan fungsi pendaftaran wajah kamu
  child: Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blue, // Bisa disesuaikan warnanya
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Icon(
      Icons.keyboard_arrow_right,
      color: Colors.white,
      size: 30,
    ),
  ),
)

      ],
    );
  }
}