import 'dart:ffi';

import 'package:bookes/widgets/confirmDialog.dart';
import 'package:bookes/widgets/ratingDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    print(transactionId);
    print(isLenderView);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: FutureBuilder(
              future: Future.wait([
                // Fetch user data
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(isLenderView
                        ? transaction['borrowerId']
                        : transaction['lenderId'])
                    .get(),
                // Fetch book request data with conditional query
                Future(() async {
                  final directRequests = await FirebaseFirestore.instance
                      .collection('available_books')
                 
                      .where('bookId',
                          isEqualTo: transaction['bookId'])
                      .get();

                  final otherRequests = await FirebaseFirestore.instance
                      .collection('bookRequests')
                    
                      .where('requestId', isEqualTo: transaction['requestId'])
                      .get();

                  // Combine results from both queries
                  final allDocs = [
                    ...directRequests.docs,
                    ...otherRequests.docs
                  ];
                  if (allDocs.isEmpty) {
                    throw Exception('No matching documents found');
                  }
                  return allDocs
                      .first; // or you might want to handle multiple docs differently
                })
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshots) {
                if (!snapshots.hasData) {
                  return Text(AppLocalizations.of(context)!.loading);
                }

                final userData =
                    snapshots.data![0].data() as Map<String, dynamic>;
                final bookRequestData =
                    snapshots.data![1].data() as Map<String, dynamic>;
            print(
                    'Current user is ${isLenderView ? "lender" : "borrower"}');
                print(
                    'Fetching user data for ID: ${isLenderView ? transaction['borrowerId'] : transaction['lenderId']}');
                print('Fetched user data: ${userData}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !isLenderView
                        ? Text(
                            '${AppLocalizations.of(context)!.borrowedfrom} ${userData['username']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Text(
                            '${AppLocalizations.of(context)!.lentto} ${userData['username']}',
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
            trailing: _buildStatusChip(transaction['status'], context),
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
                      label: Text(AppLocalizations.of(context)!.contactlender),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLenderView)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            takenConfirmation(context, transactionId,transaction['bookId']),
                        icon: const Icon(Icons.check),
                        label: Text(AppLocalizations.of(context)!.markastaken),
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
                      label: Text(AppLocalizations.of(context)!.contactlender),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLenderView)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            returnConfirmation(context, transactionId),
                        icon: const Icon(Icons.check),
                        label:
                            Text(AppLocalizations.of(context)!.markasreturned),
                      ),
                    ),
                ],
              ),
            ),
          if (transaction['status'] == 'completed' &&
              transaction[isLenderView ? 'borrowerRating' : 'lenderRating'] ==
                  null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _rateTransaction(context),
                child: Text(AppLocalizations.of(context)!.rateexperience),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, context) {
    Color color;
    String label;

    switch (status) {
      case 'pending_meetup':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.pendingmeetup;
        break;
      case 'ongoing':
        color = Colors.blue;
        label = AppLocalizations.of(context)!.ongoing;
        break;
      case 'completed':
        color = Colors.green;
        label = AppLocalizations.of(context)!.completed;
        break;
      case 'overdue':
        color = Colors.red;
        label = AppLocalizations.of(context)!.overdue;
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
          isLenderView: isLenderView),
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
  static Future<void> markAsTaken(BuildContext context, requestId,bookId) async {
    await FirebaseFirestore.instance
        .collection('directBookRequests')
        .doc(requestId)
        .update({
      'status': 'ongoing',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
        await FirebaseFirestore.instance
        .collection('available_books')
        .doc(bookId)
        .update({
      'status': 'borrowed',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
    // await FirebaseFirestore.instance
    //     .collection('bookTransactions')
    //     .doc(requestId)
    //     .update({
    //   'status': 'ongoing',
    //   'actualReturnDate': FieldValue.serverTimestamp(),
    // });
  }

  static Future<void> markAsReturned(
      BuildContext context, transactionId) async {
    await FirebaseFirestore.instance
        .collection('bookTransactions')
        .doc(transactionId)
        .update({
      'status': 'completed',
      'actualReturnDate': FieldValue.serverTimestamp(),
    });
  }
}
