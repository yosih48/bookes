import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class BookCard extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> data;
  final VoidCallback onRequestPress;

  const BookCard({
    Key? key,
    required this.bookId,
    required this.data,
    required this.onRequestPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: data['imageUrl'] != null
                ? Image.network(
                    data['imageUrl'],
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(LucideIcons.bookX, color: Colors.grey[400]),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[300],
                    child: Icon(LucideIcons.book, color: Colors.grey[400]),
                  ),
          ),
          SizedBox(width: 16.0),
          
          // Book Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Unknown Title',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text('by ${data['author'] ?? 'Unknown Author'}'),
                SizedBox(height: 4.0),
                Text('Condition: ${data['condition'] ?? 'Not specified'}'),
                SizedBox(height: 4.0),
                Text(data['location'] ?? 'Location not specified'),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(LucideIcons.clock4, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(data['createdAt'] as Timestamp),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Request Button
          ElevatedButton(
            onPressed: onRequestPress,
            child: Text(AppLocalizations.of(context)!.requestToBorrow),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${DateFormat('MMM d').format(date)}';
    }
  }
}