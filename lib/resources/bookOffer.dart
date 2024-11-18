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

}
