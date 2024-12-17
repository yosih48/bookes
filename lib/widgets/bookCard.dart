import 'package:bookes/widgets/BookImageWidget.dart';
import 'package:bookes/widgets/bookesCardDetailRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
       final userId = FirebaseAuth.instance.currentUser?.uid;
    return  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
            .collection('directBookRequests')
            .where('requesterId', isEqualTo: userId)
            .where('bookId', isEqualTo: bookId)
            .snapshots(),
      builder: (context, snapshot) {
          final bool hasRequested =
              snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Cover Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                        width: 40,
                  height: 220,
            child: BookImageWidget(imageUrl: data['imageUrl']),
                ),
              ),
              
              // Book Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Unknown Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${data['author'] ?? 'Unknown Author'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'Genre: ${book['genre'] ?? 'Unspecified'}',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.grey[500],
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                   onPressed: hasRequested ? null : onRequestPress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                    child: Text(hasRequested
                              ? 'Already Requested'
                              : 'View & Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
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
