import 'package:bookes/models/BookRequest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class BookRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BookRequest> createBookRequest(BookRequest request) async {

        try {
      // Generate a new document reference with an automatic ID
      final docRef = _firestore.collection('bookRequests').doc();

      // Set the generated ID as the requestId in the BookRequest object
      request = request.copyWith(requestId: docRef.id);

      // Save the BookRequest to Firestore with the custom ID
      await docRef.set(request.toMap());

      // Fetch the saved document to return it as a BookRequest object
      final docSnapshot = await docRef.get();
      return BookRequest.fromFirestore(docSnapshot);
    } catch (e) {
      throw 'Failed to create book request: $e';
    }
  
  }

  Future<List<BookRequest>> getBookRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('bookRequests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BookRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch book requests: $e';
    }
  }

  Future<List<BookRequest>> getNearbyRequests(
    GeoPoint center,
    double radiusInKm,
  ) async {
    try {
      // Get all requests first (you might want to limit this in production)
      final querySnapshot = await _firestore
          .collection('bookRequests')
          .orderBy('createdAt', descending: true)
          
          .get();

      // Filter requests by distance
      final requests = querySnapshot.docs
          .map((doc) => BookRequest.fromFirestore(doc))
          .where((request) {
        final distance = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          request.coordinates.latitude,
          request.coordinates.longitude,
        );
        return distance <= (radiusInKm * 1000); // Convert km to meters
      }).toList();

      return requests;
    } catch (e) {
      throw 'Failed to fetch nearby requests: $e';
    }
  }
}
