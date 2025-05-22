import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:richzspot/core/constant/app_colors.dart';

class ReceiptUploadWidget extends StatelessWidget {
  final Function(String) onImageSelected;
  final String? currentImage;

  const ReceiptUploadWidget({
    Key? key,
    required this.onImageSelected,
    this.currentImage,
  }) : super(key: key);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onImageSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Receipt', style: AppColors.label),
        const SizedBox(height: 8),
        if (currentImage == null)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 94,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_outlined,
                    size: 32,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Receipt',
                    style: AppColors.label.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              Container(
                height: 201,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(currentImage!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onImageSelected(''),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
