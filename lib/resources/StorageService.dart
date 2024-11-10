// lib/services/storage_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
   final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  Future<String> uploadImage({
    required File imageFile,
    required String path,
    String? fileName,
  }) async {
    try {
    if (_auth.currentUser == null) {
        throw 'User must be authenticated to upload images';
      }


      // Create a unique filename if none provided
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}.jpg';
      print(fileName);
      // Create the full path
      final fullPath = '$path/$fileName';
       print(fullPath);
      // Create reference
      final storageRef = _storage.ref().child(fullPath);
        print(storageRef);
      // Upload file
       final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': _auth.currentUser!.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
        await storageRef.putFile(imageFile, metadata);
      
      // Get download URL
      final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);
      return imageUrl;
    } catch (e) {
      if (e is FirebaseException) {
        throw 'Firebase Storage Error: ${e.message}';
      }
      throw 'Failed to upload image: $e';
    }
  }

  Future<void> deleteImage(String imageUrl) async {
  try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        throw 'User must be authenticated to delete images';
      }

      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      if (e is FirebaseException) {
        throw 'Firebase Storage Error: ${e.message}';
      }
      throw 'Failed to delete image: $e';
    }
  }
}