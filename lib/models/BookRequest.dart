import 'package:cloud_firestore/cloud_firestore.dart';

class BookRequest {
  final String? requestId;
  final String userId;
  final String title;
  final String author;
  final String condition;
  final String location;
  final GeoPoint coordinates; // For storing latitude and longitude
  final DateTime createdAt;
    final String? imageUrl; 
    final String status;

  BookRequest({
    this.requestId,
    required this.userId,
    required this.title,
    required this.author,
    required this.condition,
    required this.location,
    required this.coordinates,
    required this.createdAt,
     this.imageUrl,
         required this.status,
  });

  BookRequest copyWith({
    String? requestId,
    String? userId,
    String? title,
    String? author,
    String? condition,
    String? location,
    String? imageUrl,
    GeoPoint? coordinates,
    DateTime? createdAt,
    String? status,
  }) {
    return BookRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }



  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'title': title,
      'author': author,
      'condition': condition,
      'location': location,
      'coordinates': coordinates,
      'createdAt': createdAt,
      'status': status,
        'imageUrl': imageUrl,
    };
  }

  // Create BookRequest from Firestore document
  factory BookRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookRequest(
          requestId: doc.id, // Assign the provided requestId
      userId: data['userId'],
      title: data['title'],
      author: data['author'],
      condition: data['condition'],
      location: data['location'],
      imageUrl: data['imageUrl'],
      status: data['status'],
      coordinates: data['coordinates'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

}
