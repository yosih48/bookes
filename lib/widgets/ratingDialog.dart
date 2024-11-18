import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String transactionId;
  final String lenderId;
  final String borrowerId;
final bool isLenderView;
  const RatingDialog({
    Key? key,
    required this.transactionId,
    required this.lenderId,
    required this.borrowerId,
    required this.isLenderView,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 3.0;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Experience'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Leave a comment (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submitRating(context),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitRating(BuildContext context) async {
    try {
      // Start a batch write
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update the transaction with the rating
      final transactionRef = FirebaseFirestore.instance
          .collection('bookTransactions')
          .doc(widget.transactionId);

if(widget.isLenderView){

      batch.update(transactionRef, {
        'borrowerRating': _rating,
        'borrowerComment': _commentController.text.trim(),
        'ratedAt': FieldValue.serverTimestamp(),
      });
}else{
        batch.update(transactionRef, {
        'lenderRating': _rating,
        'lenderComment': _commentController.text.trim(),
        'ratedAt': FieldValue.serverTimestamp(),
      });
}

      // 2. Get the lender's current rating data
      final lenderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc( widget.isLenderView? widget.borrowerId: widget.lenderId)
          .get();

      final userData = lenderDoc.data() as Map<String, dynamic>;
      final currentRating = userData['rating'] ?? 0.0;
      final currentTotalRatings = userData['totalRatings'] ?? 0;

      // 3. Calculate new rating
      final newTotalRatings = currentTotalRatings + 1;
      final newRating =
          ((currentRating * currentTotalRatings) + _rating) / newTotalRatings;

      // 4. Update the lender's rating
      final lenderRef =
          FirebaseFirestore.instance.collection('users').doc(widget.isLenderView? widget.borrowerId: widget.lenderId);

      batch.update(lenderRef, {
        'rating': newRating,
        'totalRatings': newTotalRatings,
      });

      // 5. Commit the batch
      await batch.commit();

      // 6. Close the dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
