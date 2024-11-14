import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
              if (request['status'] == 'Active')
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
      case 'Active':
        color = Colors.blue;
        label = 'Active';
        break;
      case 'fulfilled':
        color = Colors.green;
        label = 'Fulfilled';
        break;
      case 'cancelled':
        color = Colors.red;
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
String _formatDate(dynamic date) {
  if (date == null) return 'Unknown date';
  if (date is Timestamp) {
    return DateFormat('MMM d, yyyy').format(date.toDate());
  }
  return 'Invalid date';
}
