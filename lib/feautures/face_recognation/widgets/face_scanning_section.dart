import 'package:flutter/material.dart';

class FaceScanningSection extends StatelessWidget {
  const FaceScanningSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 244,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Align your face within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/d26e9bede4d82e49b467595986186f957be1e160?placeholderIfAbsent=true',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/d39919ea6e84052184e7e39e7d37368ac54eed2f?placeholderIfAbsent=true',
                width: 8,
                height: 8,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
