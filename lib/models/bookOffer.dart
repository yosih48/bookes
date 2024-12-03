import 'package:cloud_firestore/cloud_firestore.dart';

class BookOffer {
  final String requestId;
  final String offererId;
  final String offerType;
  final String requesterId;
  final String status; // expected values: "pending", "accepted", "declined"
  // final String message;
  final DateTime createdAt;
  // final DateTime? responseAt;

  BookOffer({
    required this.requestId,
    required this.offererId,
    required this.offerType,
    required this.requesterId,
    required this.status,
    // required this.message,
    required this.createdAt,
    // this.responseAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'offererId': offererId,
      'offerType': offerType,
      'requesterId': requesterId,
      'status': status,
      'createdAt': createdAt,
    };
  }
  factory BookOffer.fromMap(Map<String, dynamic> map) {
    return BookOffer(
      requestId: map['requestId'] as String,
      offererId: map['offererId'] as String,
      offerType: map['offerType'] as String,
      requesterId: map['requesterId'] as String,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  

  // Factory method to create an instance from JSON
  factory BookOffer.fromJson(Map<String, dynamic> json) {
    return BookOffer(
      requestId: json['requestId'] as String,
      offerType: json['offerType'] as String,
      offererId: json['offererId'] as String,
      requesterId: json['requesterId'] as String,
      status: json['status'] as String,
      // message: json['message'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      // responseAt: json['responseAt'] != null
      //     ? (json['responseAt'] as Timestamp).toDate()
      //     : null,
    );
  }
  

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'offererId': offererId,
      'offerType': offerType,
      'requesterId': requesterId,
      'status': status,
      // 'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      // 'responseAt': responseAt != null ? Timestamp.fromDate(responseAt!) : null,
    };
  }
}
