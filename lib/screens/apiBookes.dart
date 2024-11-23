import 'package:bookes/widgets/bookCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class MainDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to calculate distance (you'll need to implement this based on user's location)
  String _calculateDistance(GeoPoint bookLocation, GeoPoint? userLocation) {
    // Implement distance calculation logic here
    // For now returning placeholder
    return "0.5 mi away";
  }


  void _handleBookRequest(BuildContext context, String bookId, Map<String, dynamic> bookData) async {
    // Implement your book request logic here
    // You might want to show a dialog or navigate to a request screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.requestBook),
        content: Text(AppLocalizations.of(context)!.confirmBookRequest),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement request logic
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookedUp'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchBooksNearYou,
                prefixIcon: Icon(LucideIcons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              // TODO: Implement search functionality
              onChanged: (value) {
                // Add search logic
              },
            ),
            SizedBox(height: 16.0),

            // Nearby Books Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nearbyBooks,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to map view
                  },
                  icon: Icon(LucideIcons.map),
                  label: Text(AppLocalizations.of(context)!.viewOnMap),
                ),
              ],
            ),

            // Available Books Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('available_books')
                    .where('status', isEqualTo: 'Available')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.errorLoadingBooks),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bookX, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noBooksAvailable),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.0),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return BookCard(
                        bookId: doc.id,
                        data: data,
                        onRequestPress: () => _handleBookRequest(context, doc.id, data),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 16.0),

            // User Profile Section (You might want to make this a separate stream)
            // StreamBuilder<DocumentSnapshot>(
            //   stream: _firestore
            //       .collection('users')
            //       .doc(FirebaseAuth.instance.currentUser?.uid)
            //       .snapshots(),
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return SizedBox.shrink();
            //     }

            //     final userData = snapshot.data!.data() as Map<String, dynamic>?;
            //     if (userData == null) return SizedBox.shrink();

            //     return UserProfileWidget(userData: userData);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

}