import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';

class ProductImageCaptureButtons extends StatelessWidget {
  final Function(ImageSource) onImageCapturePressed;

  const ProductImageCaptureButtons({
    super.key,
    required this.onImageCapturePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner_outlined,
              color: AppColors.primaryBlack),
          label: Text("Scan Now", style: AppTextStyles.buttonTextBlack),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppColors.primaryWhite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => onImageCapturePressed(ImageSource.camera),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.photo_library,
              color: Theme.of(context).colorScheme.onSurface),
          label: Text("Gallery", style: AppTextStyles.buttonTextWhite),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.cardBackground,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => onImageCapturePressed(ImageSource.gallery),
        ),
      ],
    );
  }
}

class FoodImageCaptureButtons extends StatelessWidget {
  final Function(ImageSource) onImageCapturePressed;

  const FoodImageCaptureButtons({
    super.key,
    required this.onImageCapturePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt_outlined,
              color: Theme.of(context).colorScheme.onPrimary),
          label: const Text(
            "Take Photo",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
          ),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => onImageCapturePressed(ImageSource.camera),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.photo_library,
              color: Theme.of(context).colorScheme.onPrimary),
          label: const Text(
            "Gallery",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
          ),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.cardBackground,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => onImageCapturePressed(ImageSource.gallery),
        ),
      ],
    );
  }
}
