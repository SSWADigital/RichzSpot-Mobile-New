import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? actionIcon;
  final bool isToggle;
  final bool isDestructive;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.label,
    this.actionIcon,
    this.isToggle = false,
    this.isDestructive = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
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
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF111827),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    height: 1,
                  ),
                ),
              ],
            ),
            if (isToggle)
              Container(
                width: 38,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              IconButton(
          onPressed: () {

          },
          icon: Icon(
            Icons.keyboard_arrow_right
          ),
          )
          ],
        ),
      ),
    );
  }
}
