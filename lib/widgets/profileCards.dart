import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String requestId;

  const _RequestCard({
    Key? key,
    required this.request,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookOffers')
          .where('requestId', isEqualTo: requestId)
          .snapshots(),
      builder: (context, snapshot) {
        int offersCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    request['imageUrl'] ?? '',
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.book),
                    ),
                  ),
                ),
                title: Text(
                  request['title'] ?? 'Unknown Book',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(request['author'] ?? 'Unknown Author'),
                trailing: _buildStatusChip(request['status']),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted ${_formatDate(request['createdAt'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$offersCount offers',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (request['status'] == 'active')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelRequest(context),
                          child: const Text('Cancel Request'),
                        ),
                      ),
                      if (offersCount > 0) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _viewOffers(context),
                            child: const Text('View Offers'),
                          ),
                        ),
                      ],
                    ],
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
      case 'active':
        color = Colors.blue;
        label = 'Active';
        break;
      case 'fulfilled':
        color = Colors.green;
        label = 'Fulfilled';
        break;
      case 'cancelled':
        color = Colors.grey;
        label = 'Cancelled';
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

  void _cancelRequest(BuildContext context) {
    // Implement request cancellation
    FirebaseFirestore.instance
        .collection('bookRequests')
        .doc(requestId)
        .update({'status': 'cancelled'});
  }

  void _viewOffers(BuildContext context) {
    // Navigate to offers view
    // Implement navigation to a detailed offers view
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final String offerId;

  const _OfferCard({
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
                  userData['displayName'] ?? 'Unknown User',
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

  void _openChat(BuildContext context) {
    // Navigate to chat screen
    // Implement navigation to chat screen
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String transactionId;

  const _TransactionCard({
    Key? key,
    required this.transaction,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(transaction['lenderId'])
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Loading...');
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  'Borrowed from ${userData['displayName']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            subtitle: Text(_formatDate(transaction['startDate'])),
            trailing: _buildStatusChip(transaction['status']),
          ),
          if (transaction['status'] == 'ongoing')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(context),
                      icon: const Icon(Icons.chat),
                      label: const Text('Contact Lender'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markAsReturned(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Mark as Returned'),
                    ),
                  ),
                ],
              ),
            ),
          if (transaction['status'] == 'completed' &&
              transaction['borrowerRating'] == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _rateTransaction(context),
                child: const Text('Rate Experience'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;

    switch (status) {
      case 'pending_meetup':
        color = Colors.orange;
        label = 'Pending Meetup';
        break;
      case 'ongoing':
        color = Colors.blue;
        label = 'Ongoing';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Overdue';
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

  void _openChat(BuildContext context) {
    // Navigate to chat screen using transaction['chatId']
  }

  Future<void> _markAsReturned(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('bookTransactions')
        .doc(transactionId)
        .update({
      'status': 'completed',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
  }

  void _rateTransaction(BuildContext context) {
    // Implement rating dialog/screen
  }
}

String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}
