import 'dart:typed_data';
import 'package:bookes/models/users.dart' as model;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
String userId = FirebaseAuth.instance.currentUser!.uid;
class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String?> updateFCMToken(String uid) async {

    print(" _updateFCMToken");
    print(uid);
    User? user = _auth.currentUser;
    if (user == null) return null;
    try {
      // Request permission for notifications (important for iOS)
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get the token
      String? token = await _messaging.getToken();

      if (token != null) {
        // Update the user document with the new token
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }

      // Set up token refresh listener
      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': newToken,
        });
      });

      return token;
    } catch (e) {
      print('Error updating FCM token: $e');
      return null;
    }
  }

  //signupo user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    String res = "some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
        //regisrer user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        //add user to db
        //new way:
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
        );
        _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
//old way:
        // _firestore.collection('users').doc(cred.user!.uid).set({
        //   'username': username,
        //   'uid': cred.user!.uid,
        //   "email": email,

        // });

        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (err.code == 'week-password') {
        res = 'Password shuld be at least 6 characters';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //login in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCred.user != null) {
          // Update FCM token after successful login
          await updateFCMToken(userCred.user!.uid);

          // Get user data and update local model
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(userCred.user!.uid)
              .get();

          model.User user = model.User.fromSnap(userDoc);
          res = "success";
        }
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase
       // Get the current user's ID before signing out
      String? uid = _auth.currentUser?.uid;

      if (uid != null) {
        // Update FCM token to null for the current user
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': null,
        });
      }
      await _auth.signOut();
      // Verify the user is signed out by checking the current user
      if (_auth.currentUser == null) {
        print("User successfully signed out");

        // Navigate to the login screen
        // Navigator.of(context).pushReplacementNamed('/login');
      } else {
        print("Sign-out failed. User is still logged in.");
      }
    } catch (e) {
      print("Error signing out: $e");
      // Handle errors appropriately, perhaps show a message to the user
    }
  }
}
