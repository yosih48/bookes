import 'package:cloud_firestore/cloud_firestore.dart';

class DirectBookRequest {
   final String? requestId;
  final String requesterId;

  final String ownerId;
  final String bookId;

  final DateTime createdAt;

  final String status;

  DirectBookRequest({
      this.requestId,
   required this.requesterId,


   required this.ownerId,
   required this.bookId,

    required this.createdAt,

    required this.status,
  });

  DirectBookRequest copyWith({
    String? requestId,
    String? requesterId,
  
    String? ownerId,
    String? bookId,

    DateTime? createdAt,
    String? status,
  }) {
    return DirectBookRequest(
      requestId: requestId ?? this.requestId,
      requesterId: requesterId ?? this.requesterId,

      ownerId: ownerId ?? this.ownerId,
      bookId: bookId ?? this.bookId,

      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
 
      'ownerId': ownerId,
      'bookId': bookId,

      'createdAt': createdAt,
      'status': status,

    };
  }

  // Create BookRequest from Firestore document
  factory DirectBookRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DirectBookRequest(
      requestId: doc.id, // Assign the provided requestId

      ownerId: data['ownerId'] ?? 'null',
      requesterId: data['requesterId'] ?? 'null',
      bookId: data['bookId'] ?? 'null',

      status: data['status'],

      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
