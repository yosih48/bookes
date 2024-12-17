import 'package:bookes/utils.dart/global_variables.dart';
import 'package:bookes/widgets/confirmDialog.dart';
import 'package:bookes/widgets/offersTab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String requestId;

  const RequestCard({
    Key? key,
    required this.request,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('available_books')
          .where('bookId', isEqualTo: request['bookId'])
          .snapshots(),
      builder: (context, snapshot) {
        int offersCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
              if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
         final bookDoc = snapshot.data!.docs.isNotEmpty ? snapshot.data!.docs.first : null;
        final bookData = bookDoc?.data() as Map<String, dynamic>?;
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
                    bookData!['imageUrl'] ?? '',
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
                  bookData!['title'] ?? 'Unknown Book',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(bookData!['author'] ?? 'Unknown Author'),
                trailing: _buildStatusChip(request!['status'], context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.posted} ${_formatDate(bookData!['createdAt'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // if (request['requestType'] != 'DirectRequest')
                    //   Row(
                    //     children: [
                    //       Icon(Icons.people_outline,
                    //           size: 16, color: Colors.grey[600]),
                    //       const SizedBox(width: 4),
                    //       Text(
                    //         '$offersCount ${AppLocalizations.of(context)!.offersCount}',
                    //         style: TextStyle(color: Colors.grey[600]),
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
              ),
              if (request['status'] == 'Active' ||
                  request['status'] == 'Pending Owner')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              showCancelRequestConfirmation(context, requestId),
                          child:
                              Text(AppLocalizations.of(context)!.cancelrequest),
                        ),
                      ),
                      // if (offersCount > 0) ...[
                      //   const SizedBox(width: 8),
                      //   Expanded(
                      //     child: ElevatedButton(
                      //       onPressed: () => _viewOffers(context),
                      //       child: const Text('View Offers'),
                      //     ),
                      //   ),
                      // ],
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
      case 'Active':
        color = Colors.blue;
        label = AppLocalizations.of(context)!.active;
        break;
      case 'fulfilled':
        color = Colors.green;
        label = AppLocalizations.of(context)!.fulfilled;
        break;
      case 'accepted':
        color = Colors.green;
        label = AppLocalizations.of(context)!.accepted;
        break;
      case 'cancelled':
        color = Colors.red;
        label = AppLocalizations.of(context)!.cancelled;
        break;
      case 'Pending Owner':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.pendingOwner;
        break;
      case 'ongoing':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.active;
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

  void _viewOffers(BuildContext context) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         OffersTab(userId: userId), // Pass the userId if required
    //   ),
    // );
  }
}

String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}

class RequestService {
  static Future<void> cancelRequest(BuildContext context, requestId) async {
    // Implement request cancellation
    FirebaseFirestore.instance
        .collection('bookRequests')
        .doc(requestId)
        .update({'status': 'cancelled'});
  }
}
