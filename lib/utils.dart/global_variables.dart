import 'package:bookes/screens/BookRequestsScreen.dart';

import 'package:bookes/screens/apiBookes.dart';
import 'package:bookes/screens/bookesForm.dart';
import 'package:bookes/screens/login.dart';
import 'package:bookes/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

  String userId = FirebaseAuth.instance.currentUser!.uid;
const webScreenSize = 600;

List<Widget> homeScreenItems = [
// MyWidget(),
ProfileScreen(),
// LoginScreen(),
MainDashboard(),
BookRequestsScreen(),
BookRequestScreen()
];
