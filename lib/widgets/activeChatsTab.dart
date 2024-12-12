import 'package:bookes/screens/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ChatListItem extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final Timestamp? lastMessageTimestamp;
  final String currentUserId;
  final String offerId;

  const ChatListItem({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.currentUserId,
    required this.offerId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(),
              title: Text(AppLocalizations.of(context)!.loading),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatId,
                    currentUserId: currentUserId,
                    otherUserId: otherUserId,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
            ),
            title: Text(
              userData['username'] ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (lastMessageTimestamp != null)
                  Text(
                    _formatTimestamp(lastMessageTimestamp!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            trailing: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('bookTransactions')
                  .where('requestId', isEqualTo: offerId)
                  .limit(1)
                  .get()
                  .then((snapshot) => snapshot.docs.first),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final transaction =
                    snapshot.data!.data() as Map<String, dynamic>;
                return _buildStatusChip(transaction['status'], context);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status, context) {
    Color color;
    String label;

    switch (status) {
      case 'pending_meetup':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.pendingmeetup;
        break;
      case 'active':
        color = Colors.green;
        label = AppLocalizations.of(context)!.active;
        break;
      case 'completed':
        color = Colors.blue;
        label = AppLocalizations.of(context)!.completed;
        break;
      default:
        color = Colors.grey;
        label = AppLocalizations.of(context)!.unknown;
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

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
