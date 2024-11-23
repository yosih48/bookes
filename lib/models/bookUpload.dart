
import 'package:cloud_firestore/cloud_firestore.dart';
class BookUpload {
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
    required this.title,
    required this.author,
    required this.condition,
    required this.location,
    required this.imageUrl,
    required this.coordinates,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
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
}