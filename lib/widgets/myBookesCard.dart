import 'package:bookes/screens/BookRequestsScreen.dart';
import 'package:bookes/screens/myBookesRequests.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
class MyBooksCard extends StatelessWidget {

  final Map<String, dynamic> myBookes;

  const MyBooksCard({super.key, required this.myBookes});

  @override
  Widget build(BuildContext context) {
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
                myBookes['imageUrl'] ?? '',
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
              myBookes['title'] ?? 'Unknown Book',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(myBookes['author'] ?? 'Unknown Author'),
            trailing: _buildStatusChip(myBookes['status'], context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.posted} ${_formatDate(myBookes['createdAt'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
        
              ],
            ),
          ),
          if (myBookes['status'] == 'Available' )
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
           onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyBookRequestsScreen(
                              availableBookId: myBookes['availableBookId'],
                            ),
                          ),
                        );
                      },
                      child: Text('View Requests'),
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
  }
}
String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}
Widget _buildStatusChip(String? status, context) {
  Color color;
  String label;

  switch (status) {
    case 'Available':
      color = Colors.blue;
      label = AppLocalizations.of(context)!.active;
      break;
    case 'fulfilled':
      color = Colors.green;
      label = AppLocalizations.of(context)!.fulfilled;
      break;
    case 'cancelled':
      color = Colors.red;
      label = AppLocalizations.of(context)!.cancelled;
      break;
    case 'Pending Owner':
      color = Colors.orange;
      label = AppLocalizations.of(context)!.pendingOwner;
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
