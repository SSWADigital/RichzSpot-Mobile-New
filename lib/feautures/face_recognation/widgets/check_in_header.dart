import 'package:flutter/material.dart';

class CheckInHeader extends StatelessWidget {
  const CheckInHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wednesday, May 7',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              height: 1,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 7),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '06:00 PM',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
