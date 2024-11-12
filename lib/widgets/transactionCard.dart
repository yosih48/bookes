import 'package:bookes/widgets/ratingDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String transactionId;

  const TransactionCard({
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
                  'Borrowed from ${userData['username']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            subtitle: Text(_formatDate(transaction['startDate'])),
            trailing: _buildStatusChip(transaction['status']),
          ),
          if (transaction['status'] == 'pending_meetup')
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
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        transactionId: transactionId,
        lenderId: transaction['lenderId'],
      ),
    );
  }
}

String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}
