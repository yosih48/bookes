import 'dart:typed_data';
import 'package:bookes/models/users.dart'  as model;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
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
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
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
