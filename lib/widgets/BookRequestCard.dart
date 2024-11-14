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
        return 
Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Book cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: BookImageWidget(imageUrl: request.imageUrl),
                ),
              ),

              const SizedBox(width: 16.0),

              // Middle section - Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Book Details
                    _buildDetailRow(
                      Icons.person_outline,
                      'Author: ${request.author}',
                      iconSize: 16,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.inventory_2_outlined,
                      'Condition: ${request.condition}',
                      iconSize: 16,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Location: ${request.location}',
                      iconSize: 16,
                      fontSize: 14,
                    ),

                    if (distance != null) ...[
                      const SizedBox(height: 4),
                      _buildDetailRow(
                        Icons.directions_walk,
                        'Distance: ${distance!.toStringAsFixed(1)} km',
                        color: Theme.of(context).primaryColor,
                        iconSize: 16,
                        fontSize: 14,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16.0),

              // Right side - Status image and action button
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status image or icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: 100, // Fixed width for button
                    child: ElevatedButton(
                      onPressed: hasAlreadyOffered ? null : onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'I have it!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildDetailRow(
    IconData icon,
    String text, {
    Color? color,
    double iconSize = 16,
    double fontSize = 14,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color ?? Colors.grey[600],
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
