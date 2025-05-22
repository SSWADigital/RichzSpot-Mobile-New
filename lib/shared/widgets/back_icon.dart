import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

class BackIcon extends StatelessWidget {
  final BuildContext context;

  const BackIcon({
    super.key,
    required this.context
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
                    onPressed: () {
                      Navigator.pop(this.context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new) 
  );

  }
  
}