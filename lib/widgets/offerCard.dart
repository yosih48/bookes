import 'package:bookes/screens/chatScreen.dart';
import 'package:bookes/widgets/confirmDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final String offerId;
  final bool isLenderView;
  const OfferCard({
    Key? key,
    required this.offer,
    required this.offerId,
    this.isLenderView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        // Fetch user data
        FirebaseFirestore.instance
            .collection('users')
            .doc(
              offer['offerType'] != "AvailableOffer"
                ? isLenderView
                    ? 
                    offer['requesterId']
                    : offer['offererId']
                : offer['offererId']
                )
            .get(),
        // Fetch book data based on offer type
        FirebaseFirestore.instance
            .collection(offer['offerType'] == "AvailableOffer"
                ? 'available_books'
                : 'bookRequests')
            .doc(offer['requestId']) // For direct offers
            .get(),
      ]),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshots.hasError) {
          return Card(
            child: Center(
              child: Text('Error: ${snapshots.error}'),
            ),
          );
        }

        if (!snapshots.hasData ||
            snapshots.data == null ||
            snapshots.data!.length != 2 ||
            !snapshots.data![0].exists ||
            !snapshots.data![1].exists) {
          return const Card(
            child: Center(
              child: Text('No data available'),
            ),
          );
        }

        // Safely cast the data
        final userData = snapshots.data![0].data() as Map<String, dynamic>?;
        final bookData = snapshots.data![1].data() as Map<String, dynamic>?;

        if (userData == null || bookData == null) {
          return const Card(
            child: Center(
              child: Text('Invalid data format'),
            ),
          );
        }
      

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
                ),
                title: Text(
                  userData['username'] ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                    Text(' ${userData['rating']?.toStringAsFixed(1) ?? '0.0'}'),
                  ],
                ),
                trailing: _buildStatusChip(offer['status'], context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Details Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book Title Section
                          Row(
                            children: [
                              const Icon(Icons.book,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bookData['title'] ?? 'Unknown Book',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context)!.offerdate} ${_formatDate(offer['createdAt'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (offer['message']?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            Text(
                              offer['message'],
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Chat Button (if status is accepted)
                    if (offer['status'] == 'accepted') ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 36, // Fixed height for the button
                        child: ElevatedButton.icon(
                          onPressed: () => _openChat(context),
                          icon: const Icon(Icons.chat, size: 18),
                          label:  Text(
                              AppLocalizations.of(context)!.openchat),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (offer['status'] == 'pending' && !isLenderView ||
              offer['offerType'] == 'AvailableOffer' && offer['requesterId'] != 'pending'
              &&
                      offer['status'] == 'pending'
              )
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showAcceptOfferConfirmation(context, 'declined', offerId, offer),
                          child:  Text(
                              AppLocalizations.of(context)!.decline),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              showAcceptOfferConfirmation(context, 'accepted', offerId, offer),
                          child:  Text(
                              AppLocalizations.of(context)!.accept),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String? status, context) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.pending;
        break;
      case 'accepted':
        color = Colors.green;
        label = AppLocalizations.of(context)!.accepted;
        break;
      case 'declined':
        color = Colors.red;
        label = AppLocalizations.of(context)!.declined;
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }




  void _openChat(BuildContext context) async {
    try {
      // Query the chats collection to find the chat document with this offerId
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('offerId', isEqualTo: offerId)
          .limit(1)
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        final chatId = chatSnapshot.docs.first.id;

        // Navigate to chat screen
        if (context.mounted) {
          // Check if context is still valid
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                      currentUserId:
                    isLenderView ? offer['offererId'] : offer['requesterId'],
                otherUserId:
                    isLenderView ? offer['requesterId'] : offer['offererId'],
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          // Check if context is still valid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat not found')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Check if context is still valid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening chat: $e')),
        );
      }
    }
  }
}

String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}

class OfferRequestService {
  static Future<void> respondToOffer(
      BuildContext context, String response, offerId, offer) async {
    // Update offer status
    await FirebaseFirestore.instance
        .collection('bookOffers')
        .doc(offerId)
        .update({
      'status': response,
      'responseAt': FieldValue.serverTimestamp(),
    });

    if (response == 'accepted') {
      // Create a chat room
      final chatDoc = await FirebaseFirestore.instance.collection('chats').add({
        'offerId': offerId,
        'participants': [offer['offererId'], offer['requesterId']],
        'lastMessage': 'Chat started',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });

      // Create initial transaction
      await FirebaseFirestore.instance.collection('bookTransactions').add({
        'offerId': offerId,
        'requestId': offer['requestId'],
        'borrowerId': offer['requesterId'],
        'lenderId': offer['offererId'],
        'status': 'pending_meetup',
        'startDate': FieldValue.serverTimestamp(),
        'chatId': chatDoc.id,
    
      });
    }
  }
}
