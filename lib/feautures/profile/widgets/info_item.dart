import 'package:flutter/material.dart';

class InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? actionIcon;

  const InfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // IconButton(
          // onPressed: () {

          // },
          // icon: Icon(
          //   Icons.keyboard_arrow_right
          // ),
          // )
        ],
      ),
    );
  }
}
