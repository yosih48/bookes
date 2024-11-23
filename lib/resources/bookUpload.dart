import 'package:bookes/models/bookUpload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookUploadService {
  final CollectionReference _uploadsCollection = 
      FirebaseFirestore.instance.collection('available_books');

  Future<DocumentReference> createBookUpload(BookUpload bookUpload) async {
    return await _uploadsCollection.add(bookUpload.toMap());
  }
}
