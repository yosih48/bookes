import 'package:bookes/models/bookOffer.dart';
import 'package:bookes/resources/NotificationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class BookOfferService {

  final _firestore = FirebaseFirestore.instance;
   final NotificationService _notificationService = NotificationService();
  Future<BookOffer> createBookOffer(BookOffer bookOffer) async {

    print('createBookOffer');

    try {
      await _notificationService.initialize();

      await _firestore.collection('bookOffers').add(bookOffer.toMap());

      // Return the created offer
      return bookOffer;
    } catch (e) {
      debugPrint('Error creating book offer: $e');
      rethrow;
    }
  }

Future<void> updateBookOfferRequesterId(
      String requestId, String userId) async {
    try {
      // Query the bookOffers collection to find the matching document
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookOffers')
          .where('requestId', isEqualTo: requestId)
          .get();

      // Check if we found a matching document
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document's reference
        DocumentReference offerRef = querySnapshot.docs.first.reference;

        // Update the requesterId field
        await offerRef.update({'requesterId': userId});
      } else {
        print('No matching book offer found with requestId: $requestId');
      }
    } catch (e) {
      print('Error updating book offer: $e');
      throw e;
    }
  }

}
