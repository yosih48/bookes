import 'dart:ffi';

import 'package:bookes/widgets/confirmDialog.dart';
import 'package:bookes/widgets/ratingDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String transactionId;
final bool isLenderView;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.transactionId, 
    required this.isLenderView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
             title: FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait([
              // Fetch user data
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(isLenderView ? transaction['borrowerId'] : transaction['lenderId'])
                  .get(),
              // Fetch book request data
              FirebaseFirestore.instance
                  .collection('bookRequests')
                  .doc(transaction['requestId'])
                  .get(),
            ]),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
              if (!snapshots.hasData) {
                return const Text('Loading...');
              }
              
              final userData = snapshots.data![0].data() as Map<String, dynamic>;
              final bookRequestData = snapshots.data![1].data() as Map<String, dynamic>;
        return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isLenderView
                      ? Text(
                          'Borrowed from ${userData['username']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Lent to ${userData['username']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                  Row(
                    children: [
                      const Icon(Icons.book, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bookRequestData['title'] ?? 'Unknown Book',
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
                ],
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
                if(isLenderView)
                Expanded(
                          child: OutlinedButton.icon(
                    onPressed: () => takenConfirmation(context,transactionId),
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Taken'),
                  ),
          
                ),
              ],
            ),
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
                if(isLenderView)
                Expanded(
                    child: OutlinedButton.icon(
                    onPressed: () =>  returnConfirmation(context, transactionId),
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Returned'),
                  ),
                ),
              ],
            ),
          ),
        if (transaction['status'] == 'completed' &&
            transaction[isLenderView? 'borrowerRating': 'lenderRating'] == null)
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






void _rateTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        transactionId: transactionId,
        lenderId: transaction['lenderId'],
        borrowerId: transaction['borrowerId'],
        isLenderView: isLenderView
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
class TransactionRequestService {
  static Future<void> markAsTaken(BuildContext context, transactionId) async {
    await FirebaseFirestore.instance
        .collection('bookTransactions')
        .doc(transactionId)
        .update({
      'status': 'ongoing',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
  }
static   Future<void> markAsReturned(BuildContext context, transactionId) async {
    await FirebaseFirestore.instance
        .collection('bookTransactions')
        .doc(transactionId)
        .update({
      'status': 'completed',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
  }

}
