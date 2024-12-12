import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/resources/BookRequest.dart';
import 'package:bookes/resources/bookOffer.dart';
import 'package:bookes/resources/locationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';

import '../models/directBookRequests.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailsScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
   String userId = FirebaseAuth.instance.currentUser!.uid;
String _location = 'Unknown';

  String _selectedLocation = '';

  Position? _currentPosition;

  final LocationService _locationService = LocationService();

  // Function to calculate distance (you'll need to implement this based on user's location)
  String _calculateDistance(GeoPoint bookLocation, GeoPoint? userLocation) {
    // Implement distance calculation logic here
    // For now returning placeholder
    return "0.5 mi away";
  }

  void _fetchLocation() async {
    String? location = await _locationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        _location = location;
      });
    } else {
      print('Failed to fetch location');
    }
  }

  void _handleBookRequest(BuildContext context,
      Map<String, dynamic> bookData) async {
    print(bookData);
    print(bookData['title']);

    final location = _selectedLocation;
    final coordinates = _currentPosition != null
        ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
        : const GeoPoint(0, 0);

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
            onPressed: () async {
              print(bookData);
              print(bookData['title']);
              print(bookData['availableBookId']);
              final bool isDirect = true;

              final bookRequest = DirectBookRequest(
                  requesterId: userId,
                 
                   bookId: bookData['bookId'],
     
                  createdAt: DateTime.now(),
                  status: 'Pending Owner',
                  ownerId: bookData['ownerId']);
              await BookRequestService().createDirectBookRequest(bookRequest, isDirect);
              //  await BookOfferService().updateBookOfferRequesterId(
              //     bookData['availableBookId'], userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.bookRequestSubmitted),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDetailRow(IconData icon, String text, {
    double iconSize = 16,
    double fontSize = 14,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color ?? Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.bookDetails),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 120,
                          height: 180,
                          child: Image.network(
                            widget.book['imageUrl'] ?? 'placeholder_url',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.book, size: 50, color: Colors.grey[400]),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Book Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book['title'] ?? 'Unknown Title',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.person_outline,
                              'Author: ${widget.book['author']}',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.inventory_2_outlined,
                              'Condition: ${widget.book['condition']}',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.location_on_outlined,
                              'Location: ${widget.book['location']}',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.access_time,
                              'Listed: ${_formatDate(widget.book['createdAt'])}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Owner Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.bookOwner,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where('uid', isEqualTo: widget.book['userId'])
                            .limit(1)
                            .get()
                            .then((snapshot) => snapshot.docs.first),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Text('Owner information not available');
                          }

                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData['username'] ?? 'Unknown User',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (userData['rating'] as num?)?.toStringAsFixed(1) ?? '0.0',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                           _handleBookRequest(context, widget.book);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.requestToBorrow,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}