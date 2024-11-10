import 'package:bookes/models/BookRequest.dart';
import 'package:flutter/material.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequest request;
  final double? distance;

  const BookRequestCard({
    Key? key,
    required this.request,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          request.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${request.author}'),
            Text('Condition: ${request.condition}'),
            Text('Location: ${request.location}'),
            if (distance != null)
              Text(
                'Distance: ${distance!.toStringAsFixed(1)} km',
                style: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
        trailing: Text(
          _formatDate(request.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          // Navigate to request details screen
          // You can implement this later
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // You can use intl package for better date formatting
    return '${date.day}/${date.month}/${date.year}';
  }
}
