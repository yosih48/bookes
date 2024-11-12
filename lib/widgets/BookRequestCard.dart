import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/widgets/BookImageWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequest request;
  final double? distance;
  final VoidCallback? onButtonPressed;
  final String currentUserId;
  const BookRequestCard({
    Key? key,
    required this.request,
    required this.currentUserId,
    this.distance,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (request.userId == currentUserId) {
      return const SizedBox
          .shrink(); // Return empty widget if user is requester
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookOffers')
          .where('requestId', isEqualTo: request.requestId)
          .where('offererId', isEqualTo: currentUserId)
       
          .snapshots(),
      builder: (context, snapshot) {
        bool hasAlreadyOffered = false;

        if (snapshot.hasData && snapshot.data != null) {
          hasAlreadyOffered = snapshot.data!.docs.isNotEmpty;
        }
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to book details
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with gradient overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: BookImageWidget(imageUrl: request.imageUrl),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(request.createdAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Book Details
                      _buildDetailRow(
                          Icons.person_outline, 'Author: ${request.author}'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.inventory_2_outlined,
                          'Condition: ${request.condition}'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.location_on_outlined,
                          'Location: ${request.location}'),

                      if (distance != null) ...[
                        const SizedBox(height: 4),
                        _buildDetailRow(
                          Icons.directions_walk,
                          'Distance: ${distance!.toStringAsFixed(1)} km',
                          color: Theme.of(context).primaryColor,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:  hasAlreadyOffered ? null : onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('I have the Book!'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? Colors.grey[800],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
