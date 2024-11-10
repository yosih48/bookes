import 'package:cloud_firestore/cloud_firestore.dart';

class BookRequest {
  final String? id; 
  final String userId;
  final String title;
  final String author;
  final String condition;
  final String location;
  final GeoPoint coordinates; // For storing latitude and longitude
  final DateTime createdAt;

  BookRequest({
     this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.condition,
    required this.location,
    required this.coordinates,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'condition': condition,
      'location': location,
      'coordinates': coordinates,
      'createdAt': createdAt,
    };
  }

  // Create BookRequest from Firestore document
  factory BookRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookRequest(
     id: doc.id, // Use the Firestore document ID
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? '',
      location: data['location'] ?? '',
      coordinates: data['coordinates'] ?? const GeoPoint(0, 0),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
