import 'package:bookes/models/bookOffer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookOfferService {

  final _firestore = FirebaseFirestore.instance;

  Future<BookOffer> createBookOffer(BookOffer bookOffer) async {

    print('createBookOffer');

    try {
      final bookOffersRef = _firestore.collection('bookOffers');
      final docRef = await bookOffersRef.add({
        'requestId': bookOffer.requestId,
        'offererId': bookOffer.offererId,
        'requesterId': bookOffer.requesterId,
        'status': bookOffer.status,
        'createdAt': bookOffer.createdAt,
      });

      return BookOffer(
        requestId: bookOffer.requestId,
        offererId: bookOffer.offererId,
        requesterId: bookOffer.requesterId,
        status: bookOffer.status,
        createdAt: bookOffer.createdAt,
      );
    } catch (e) {
      debugPrint('Error creating book offer: $e');
      rethrow;
    }
  }

}
