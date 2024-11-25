import 'package:bookes/widgets/BookImageWidget.dart';
import 'package:bookes/widgets/bookesCardDetailRow.dart';
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
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: BookImageWidget(imageUrl: data['imageUrl']),
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
                         maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.0),
                   buildDetailRow(
                  Icons.person_outline,
                  '${AppLocalizations.of(context)!.author}: ${data['author']}',
                  iconSize: 16,
                  fontSize: 14,
                ),
                // Text('by ${data['author'] ?? 'Unknown Author'}'),
                SizedBox(height: 4.0),
                       buildDetailRow(
                  Icons.inventory_2_outlined,
                  '${AppLocalizations.of(context)!.condition}: ${data['condition']}',
                  iconSize: 16,
                  fontSize: 14,
                ),
           
                SizedBox(height: 4.0),
                      buildDetailRow(
                  Icons.location_on_outlined,
                  '${AppLocalizations.of(context)!.location}: ${data['location']}',
                  iconSize: 16,
                  fontSize: 14,
                ),
                     const SizedBox(height: 4),
                buildDetailRow(
                  Icons.lock_clock,
                  _formatDate(data['createdAt'] as Timestamp),
                  color: Theme.of(context).primaryColor,
                  iconSize: 16,
                  fontSize: 14,
                ),
                SizedBox(height: 8.0),
                     const Divider(),
                const SizedBox(height: 4),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: data['userId'])
                      .limit(1)
                      .get()
                      .then((snapshot) => snapshot.docs.first),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final userName = userData['username'] ?? 'Unknown';
                    final userRating =
                        (userData['rating'] as num?)?.toStringAsFixed(1) ??
                            '0.0';

                    return Row(
                      children: [
                        Expanded(
                          child: buildDetailRow(
                            Icons.account_circle_outlined,
                            '${AppLocalizations.of(context)!.by}: $userName',
                            iconSize: 16,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(
                          ' $userRating',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Row(
                //   children: [
                //     Icon(LucideIcons.clock4, size: 14, color: Colors.grey),
                //     SizedBox(width: 4),
                //     Text(
                //       _formatDate(data['createdAt'] as Timestamp),
                //       style: TextStyle(color: Colors.grey),
                //     ),
                //   ],
                // ),
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
                width: 130, // Fixed width for button
                child: ElevatedButton(
                  onPressed: 
                  onRequestPress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.requestToBorrow,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          // Request Button
          // ElevatedButton(
          //   onPressed: onRequestPress,
          //   child: Text(AppLocalizations.of(context)!.requestToBorrow),
          // ),
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