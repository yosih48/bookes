
import 'package:cloud_firestore/cloud_firestore.dart';
class BookUpload {
  final String? bookId;
  final String ownerId;
  final String title;
   final String genre;
  final String author;
  // final String condition;
  // final String location;
  final String imageUrl;
  // final GeoPoint coordinates;
  final DateTime createdAt;
  final String status;

  BookUpload({
    required this.ownerId,
   this.bookId,
    required this.title,
    required this.genre,
    required this.author,
    // required this.condition,
    // required this.location,
    required this.imageUrl,
    // required this.coordinates,
    required this.createdAt,
    required this.status,
  });
  BookUpload copyWith({

    String? ownerId,
    String? bookId,

    String? title,
    String? genre,
    String? author,
    // String? condition,
    // String? location,
    String? imageUrl,

    // GeoPoint? coordinates,
    DateTime? createdAt,
    String? status,
  }) {
    return BookUpload(
   
      ownerId: ownerId ?? this.ownerId,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      genre: genre ?? this.genre,

      author: author ?? this.author,
      // condition: condition ?? this.condition,
      // location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      // coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }




  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'bookId': bookId,
      'title': title,
      'genre': genre,
      'author': author,
      // 'condition': condition,
      // 'location': location,
      'imageUrl': imageUrl,
      // 'coordinates': coordinates,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory BookUpload.fromMap(Map<String, dynamic> map) {
    return BookUpload(
      ownerId: map['ownerId'],
      bookId: map['bookId'],
      title: map['title'],
      genre: map['genre'],
      author: map['author'],
      // condition: map['condition'],
      // location: map['location'],
      imageUrl: map['imageUrl'],
      // coordinates: map['coordinates'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'],
    );
  }

  // Create BookRequest from Firestore document
  factory BookUpload.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookUpload(
   bookId: doc.id,
      ownerId: data['ownerId'],
      title: data['title'],
      genre: data['genre'],

      author: data['author'],
      // condition: data['condition'],
      // location: data['location'],
      imageUrl: data['imageUrl'],
      status: data['status'],
      // coordinates: data['coordinates'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }



}