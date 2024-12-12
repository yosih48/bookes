import 'package:bookes/screens/chatScreen.dart';
import 'package:bookes/widgets/confirmDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class MyBookRequestsScreen extends StatelessWidget {
  final String bookId;

  const MyBookRequestsScreen({
    Key? key,
    required this.bookId,
  }) : super(key: key);


  void _openChat(BuildContext context, request) async {
    try {
      // Query the chats collection to find the chat document with this offerId
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('offerId', isEqualTo: request['requestId'])
          .limit(1)
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        final chatId = chatSnapshot.docs.first.id;

        // Navigate to chat screen
        if (context.mounted) {
          // Check if context is still valid
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                currentUserId:
                    request['ownerId'],
                otherUserId:
              request['userId'],
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          // Check if context is still valid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat not found')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Check if context is still valid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening chat: $e')),
        );
      }
    }
  }


  Future<void> _handleRequest(
    BuildContext context,
    String requestId,
    String requesterId,
    bool isAccepted,
  ) async {
    try {
      if (isAccepted) {
        // Update request status to accepted
        await FirebaseFirestore.instance
            .collection('bookRequests')
            .doc(requestId)
            .update({'status': 'Accepted'});

        // You might want to add additional logic here like:
        // - Creating a chat room
        // - Updating book availability
        // - Creating a transaction record
      } else {
        // Update request status to rejected
        await FirebaseFirestore.instance
            .collection('bookRequests')
            .doc(requestId)
            .update({'status': 'Rejected'});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAccepted ? 'Request accepted' : 'Request rejected',
          ),
          backgroundColor: isAccepted ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.requestabook),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('directBookRequests')
            .where('bookId', isEqualTo: bookId)
      
            .snapshots(),
        builder: (context, requestSnapshot) {
          if (!requestSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = requestSnapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.norequestsyet,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;
              final requesterId = request['requesterId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(requesterId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final requesterData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  requesterData['photoURL'] ?? '',
                                ),
                                radius: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      requesterData['username'] ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${requesterData['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 16),
                          // Text(
                          //   request['message'] ?? 'No message provided',
                          //   style: TextStyle(
                          //     color: Colors.grey[800],
                          //   ),
                          // ),
                          const SizedBox(height: 16),
                          if (request['status'] == 'Pending Owner')
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    onPressed: () => 
                                    // _handleRequest(
                                    //   context,
                                    //   requestId,
                                    //   requesterId,
                                    //   false,
                                    // ),
                                     showAcceptOfferConfirmation(context,
                                            'declined', requestId,  request ,false),
                                    child: Text(
                                        AppLocalizations.of(context)!.decline),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    onPressed: () => 
                                                showAcceptDirectRequestConfirmation(
                                            context,
                                         'accepted',
                                            requestId,
                                            request
                                            ),
                                    // _handleRequest(
                                    //   context,
                                    //   requestId,
                                    //   requesterId,
                                    //   true,
                                    // ),
                                    child: Text(
                                        AppLocalizations.of(context)!.accept),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: request['status'] == 'accepted'
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    request['status'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: request['status'] == 'accepted'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                           if (request['status'] == 'accepted') ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 36, // Fixed height for the button
                              child: ElevatedButton.icon(
                                onPressed: () => _openChat(context, request),
                                icon: const Icon(Icons.chat, size: 18),
                                label: Text(
                                    AppLocalizations.of(context)!.openchat),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
