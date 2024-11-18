import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;

  final String username;
  final double? rating; // Average rating
  final int? totalRatings;
  final int? booksShared;
   final  String? fcmToken;

  const User({
    required this.username,
    required this.uid,
    required this.email,
    this.rating,
    this.totalRatings,
    this.booksShared,
      this.fcmToken,
  });

  static User fromSnap(DocumentSnapshot snap) {
    print('snap in model ${snap}');
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
        rating: snapshot["rating"]?.toDouble(), // Convert to double
        booksShared: snapshot["booksShared"]?.toDouble(), // Convert to double
           fcmToken: snapshot["fcmToken"],
      totalRatings: snapshot["totalRatings"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
                "rating": rating, // Store the double value
                "booksShared": booksShared, // Store the double value
        "totalRatings": totalRatings,
           "fcmToken": fcmToken,
      };
}
