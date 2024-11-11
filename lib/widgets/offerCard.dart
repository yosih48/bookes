import 'package:bookes/screens/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final String offerId;

  const OfferCard({
    Key? key,
    required this.offer,
    required this.offerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(offer['offererId'])
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

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
                trailing: _buildStatusChip(offer['status']),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offered ${_formatDate(offer['createdAt'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (offer['message']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        offer['message'],
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              if (offer['status'] == 'pending')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _respondToOffer(context, 'declined'),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respondToOffer(context, 'accepted'),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (offer['status'] == 'accepted')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Open Chat'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'declined':
        color = Colors.red;
        label = 'Declined';
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

  Future<void> _respondToOffer(BuildContext context, String response) async {
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

  // void _openChat(BuildContext context) {
  //  Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => ChatScreen(
  //       chatId: '4Ci9gJ54U3gxBcCqAVgy', // You'll need to fetch this from Firestore
  //       currentUserId: offer['requesterId'],
  //       otherUserId: offer['offererId'],
  //     ),
  //   ),
  // );
  // }
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
      if (context.mounted) {  // Check if context is still valid
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              currentUserId: offer['requesterId'],
              otherUserId: offer['offererId'],
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {  // Check if context is still valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat not found')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {  // Check if context is still valid
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
