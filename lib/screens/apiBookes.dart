import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/resources/BookRequest.dart';
import 'package:bookes/resources/bookOffer.dart';
import 'package:bookes/resources/locationService.dart';
import 'package:bookes/screens/bookDetailsScreen.dart';
import 'package:bookes/widgets/bookCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MainDashboard extends StatefulWidget {
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String _searchTerm = '';
    String _searchFilter = 'all'; 


    bool _matchesSearch(Map<String, dynamic> bookData) {
    if (_searchTerm.isEmpty) return true;
    
    final searchTermLower = _searchTerm.toLowerCase();
    final title = (bookData['title'] as String?)?.toLowerCase() ?? '';
    final author = (bookData['author'] as String?)?.toLowerCase() ?? '';

    switch (_searchFilter) {
      case 'title':
        return title.contains(searchTermLower);
      case 'author':
        return author.contains(searchTermLower);
      default: // 'all'
        return title.contains(searchTermLower) || 
               author.contains(searchTermLower);
    } }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookedUp'),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchBooksNearYou,
                      prefixIcon: Icon(LucideIcons.book),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    // TODO: Implement search functionality
                    onChanged: (value) {
                          setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                   SizedBox(width: 8),
                             DropdownButton<String>(
                  value: _searchFilter,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'title',
                      child: Text('Title'),
                    ),
                    DropdownMenuItem(
                      value: 'author',
                      child: Text('Author'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchFilter = value ?? 'all';
                    });
                  },
                ),
              ],
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
                      child:
                          Text(AppLocalizations.of(context)!.errorLoadingBooks),
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
  
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    return _matchesSearch(doc.data() as Map<String, dynamic>);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.searchX,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noSearchResults),
                        ],
                      ),
                    );
                  }

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.searchX,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noSearchResults),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                   itemCount: filteredDocs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return BookCard(
                        bookId: doc.id,
                        data: data,
                        onRequestPress: () {
                            // _handleBookRequest(context,doc.id,  data);
                                 Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(book: data),
              ),
            );
                        }
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
