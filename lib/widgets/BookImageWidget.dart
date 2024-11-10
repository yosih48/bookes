import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
class BookImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const BookImageWidget({
    Key? key,
    this.imageUrl,
    this.width = 100,
    this.height = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      print('imageUrl == null');
      return 
          Container(
            width: 100, // Same width as image for consistency
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                LucideIcons.image,
                color: Colors.grey,
                size: 32,
              ),
            ),
          );
    }

    return 
          Container(
            width: 100, // Adjust width as needed
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
                // errorBuilder: (context, error, stackTrace) {
                //   return const Center(
                //     child: Icon(
                //       LucideIcons.imageOff,
                //       color: Colors.grey,
                //     ),
                //   );
                // },
              ),
            ),
          );
  }
}