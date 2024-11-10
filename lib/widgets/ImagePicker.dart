// lib/widgets/image_picker_widget.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File?) onImageSelected;
  final double height;
  final String placeholder;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImage,
    required this.onImageSelected,
    this.height = 200,
    this.placeholder = 'Tap to add image',
  }) : super(key: key);

  Future<void> _checkPermissionAndPickImage(BuildContext context) async {
    print('dssssss');
    try {
      // Check platform
      if (Theme.of(context).platform == TargetPlatform.android) {
        final status = await Permission.storage.status;
        if (status.isDenied) {
           print('Request permission');
          // Request permission
          final result = await Permission.storage.request();
              print(result);
          if (result.isDenied) {
                print('Permission denied');
            return; // Permission denied
          }
        }
      }
 print('dssssss');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Optional: limit image size
        maxHeight: 1200,
        imageQuality: 85, // Optional: compress image
      );

      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        selectedImage != null
            ? Container(
                height: height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => onImageSelected(null),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                    //  onTap: () => _checkPermissionAndPickImage(context),
                     onTap:  _pickImage,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.image, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(placeholder),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}