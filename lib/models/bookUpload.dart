
import 'package:cloud_firestore/cloud_firestore.dart';
class BookUpload {
  final String? availableBookId;
  final String userId;
  final String title;
  final String author;
  final String condition;
  final String location;
  final String imageUrl;
  final GeoPoint coordinates;
  final DateTime createdAt;
  final String status;

  BookUpload({
    required this.userId,
   this.availableBookId,
    required this.title,
    required this.author,
    required this.condition,
    required this.location,
    required this.imageUrl,
    required this.coordinates,
    required this.createdAt,
    required this.status,
  });
  BookUpload copyWith({

    String? userId,
    String? availableBookId,

    String? title,
    String? author,
    String? condition,
    String? location,
    String? imageUrl,

    GeoPoint? coordinates,
    DateTime? createdAt,
    String? status,
  }) {
    return BookUpload(
   
      userId: userId ?? this.userId,
      availableBookId: availableBookId ?? this.availableBookId,
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




  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'availableBookId': availableBookId,
      'title': title,
      'author': author,
      'condition': condition,
      'location': location,
      'imageUrl': imageUrl,
      'coordinates': coordinates,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory BookUpload.fromMap(Map<String, dynamic> map) {
    return BookUpload(
      userId: map['userId'],
      availableBookId: map['availableBookId'],
      title: map['title'],
      author: map['author'],
      condition: map['condition'],
      location: map['location'],
      imageUrl: map['imageUrl'],
      coordinates: map['coordinates'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'],
    );
  }

  // Create BookRequest from Firestore document
  factory BookUpload.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookUpload(
   availableBookId: doc.id,
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