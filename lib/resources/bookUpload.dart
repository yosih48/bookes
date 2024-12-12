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



  static Future<void> respondToDirectRequest(
   context, String response,request) async {

  
    // Update offer status
    await FirebaseFirestore.instance
        .collection( 'directBookRequests')
        .doc(request['requestId'])
        .update({
      'status': response,
      'responseAt': FieldValue.serverTimestamp(),
    });

    if (response == 'accepted') {
      
    await FirebaseFirestore.instance
        .collection('available_books')
        .doc(request['bookId'])
        .update({
      'status': 'Pending Meetup',
      'responseAt': FieldValue.serverTimestamp(),
    });

      // Create a chat room
      final chatDoc = await FirebaseFirestore.instance.collection('chats').add({
        'loanId':  request['requestId'],
        'participants': [request['ownerId'], request['requesterId']],
        'lastMessage': 'Chat started',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });

      // Create initial transaction
      await FirebaseFirestore.instance.collection('bookTransactions').add({
        'bookId': request['bookId'],
        'requestId': request['requestId'],
        'borrowerId': request['requesterId'],
        'lenderId': request['ownerId'],
        'status': 'pending_meetup',
        'startDate': FieldValue.serverTimestamp(),
        'chatId': chatDoc.id,
    
      });
    }
  }






}
