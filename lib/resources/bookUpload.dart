import 'package:bookes/models/bookUpload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookUploadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _uploadsCollection =
      FirebaseFirestore.instance.collection('available_books');

  Future<BookUpload>createBookUpload(BookUpload bookUpload) async {
    try {
      final docRef = _firestore
          .collection('available_books')
          .doc(bookUpload.bookId);

      // Save the BookUpload to Firestore
      await docRef.set(bookUpload.toMap());

      // Fetch the saved document to return it as a BookUpload object
      final docSnapshot = await docRef.get();

      return BookUpload.fromFirestore(docSnapshot);
    } catch (e) {
        throw 'Failed to create book request: $e';
    }

    
  }
}
