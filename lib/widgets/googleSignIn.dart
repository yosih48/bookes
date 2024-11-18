import 'package:bookes/resources/auth.dart';
import 'package:bookes/responsive/mobile_screen_layout.dart';
import 'package:bookes/responsive/rsponsive_layout_screen.dart';
import 'package:bookes/responsive/web_screen_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:bookes/models/users.dart' as model;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class GoogleSignInButton extends StatelessWidget {
  final Function(String) onSignInSuccess;
  final Function(String) onSignInError;

  GoogleSignInButton({
    required this.onSignInSuccess,
    required this.onSignInError,
  });

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '698847173183-9fn7efd3q2abj62dmjvamcuatgad0knb.apps.googleusercontent.com', // Add this line
  );


   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _createUserInFirestore(UserCredential userCredential) async {
    // Check if user document already exists
    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      // Create new user document only if it doesn't exist
      final model.User user = model.User(
        username: userCredential.user!.displayName ?? 'User',
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());
    }
      await AuthMethods().updateFCMToken(userCredential.user!.uid);
  }
  Future<void> _handleSignIn(BuildContext context) async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Sign out first to ensure a fresh sign-in attempt
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled by user');
      }

      // Get auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);




      // Get FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');

      // If we get here, sign in was successful
      if (userCredential.user != null) {

        await _createUserInFirestore(userCredential);

        // Navigate to the responsive layout
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
        
        if (googleAuth.idToken != null) {
          onSignInSuccess(googleAuth.idToken!);
        } else {
          throw Exception('Failed to obtain ID token from Google Sign-In');
        }
      } else {
        throw Exception('Failed to sign in with Firebase');
      }
    } catch (error) {
      print('Sign in error: $error');
      onSignInError(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
      child: MaterialButton(
        color: Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30.0,
              width: 30.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/googleimage.png'),
                    fit: BoxFit.cover),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(AppLocalizations.of(context)!.signinwithgoogle)
          ],
        ),
        onPressed: () {
          _handleSignIn(context);
        },
      ),
    );
    // return ElevatedButton(
    //   child: Text('Sign in with Google'),
    //   onPressed: () => _handleSignIn(context),
    // );
  }
}
