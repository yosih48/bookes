import 'package:bookes/resources/auth.dart';
import 'package:bookes/widgets/activeChatsTab.dart';
import 'package:bookes/widgets/combinedHistoryTab.dart';
import 'package:bookes/widgets/combinedOffersTab.dart';
import 'package:bookes/widgets/confirmDialog.dart';
import 'package:bookes/widgets/myBookesCard.dart';
import 'package:bookes/widgets/offerCard.dart';
import 'package:bookes/widgets/offersTab.dart';
import 'package:bookes/widgets/requestCard.dart';
import 'package:bookes/widgets/sliverAppBarDelegate.dart';
import 'package:bookes/widgets/transactionCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    print(userId);
    _tabController = TabController(length: 4, vsync: this);
  }
  final Map<String, bool> _expandedSections = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(userData),
              ),
              // Expandable Sections
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.myrequests,
                      icon: Icons.book_outlined,
                      summary: '3 Active Requests',
                      content: _RequestsTab(userId: userId),
                      sectionKey: 'requests',
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.offers,
                      icon: Icons.local_offer_outlined,
                      summary: '2 Pending Offers',
                      content: OffersTab(userId: userId),
                      sectionKey: 'offers',
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableSection(
                      title: 'My Offers',
                      icon: Icons.local_offer_outlined,
                      summary: '2 Pending Offers',
                      content: MyOffersTab(userId: userId),
                      sectionKey: 'My Offers',
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableSection(
                      title: 'My Bookes',
                      icon: Icons.local_offer_outlined,
                      summary: '2 Pending Offers',
                      content: MyBookesTab(userId: userId),
                      sectionKey: 'My Bookes',
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.history,
                      icon: Icons.history,
                      summary: '12 Completed Transactions',
                      content: MyHistoryTab(userId: userId),
                      sectionKey: 'history',
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.chats,
                      icon: Icons.chat_bubble_outline,
                      summary: '4 Active Chats',
                      content: _ActiveChatsTab(userId: userId),
                      sectionKey: 'chats',
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => showLogoutConfirmation(context),
                  child: Text(
                    AppLocalizations.of(context)!.signout,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
            ),
            const SizedBox(height: 8),
            Text(
              userData['username'] ?? 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      final rating = userData['rating'] ?? 0.0;
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.yellow[700],
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${userData['rating']?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${userData['totalRatings'] ?? '0'} ${AppLocalizations.of(context)!.ratings})',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required String summary,
    required Widget content,
    required String sectionKey,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[sectionKey] = !(_expandedSections[sectionKey] ?? false);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          summary,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expandedSections[sectionKey] ?? false
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_expandedSections[sectionKey] ?? false)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: SizedBox(
                height: 300, // Adjust this height as needed
                child: content,
              ),
            ),
        ],
      ),
    );
  }
}

  // Widget _buildProfileHeader(Map<String, dynamic> userData) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //         colors: [
  //           Theme.of(context).primaryColor,
  //           Theme.of(context).primaryColor.withOpacity(0.8),
  //         ],
  //       ),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CircleAvatar(
  //           radius: 50,
  //           backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           userData['username'] ?? 'User',
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         // Row(
  //         //   mainAxisAlignment: MainAxisAlignment.center,
  //         //   children: [
  //         //     Icon(Icons.star, color: Colors.yellow[700], size: 20),
  //         //     const SizedBox(width: 4),
  //         //     Text(
  //         //       '${userData['rating']?.toStringAsFixed(1) ?? '0.0'} (${userData['totalRatings'] ?? '0'})',
  //         //       style: const TextStyle(color: Colors.white),
  //         //     ),
  //         //   ],
  //         // ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: List.generate(5, (index) {
  //                   final rating = userData['rating'] ?? 0.0;
  //                   return Icon(
  //                     index < rating ? Icons.star : Icons.star_border,
  //                     color: Colors.yellow[700],
  //                     size: 20,
  //                   );
  //                 }),
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 '${userData['rating']?.toStringAsFixed(1) ?? '0.0'}',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(width: 4),
  //               Text(
  //                 '(${userData['totalRatings'] ?? '0'} ${AppLocalizations.of(context)!.ratings})',
  //                 style: const TextStyle(
  //                   color: Colors.white70,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


class _RequestsTab extends StatelessWidget {
  final String userId;

  const _RequestsTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            return RequestCard(
              request: request,
              requestId: requests[index].id,
            );
          },
        );
      },
    );
  }
}

class HistoryTab extends StatelessWidget {
  final String userId;

  const HistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookTransactions')
          .where('borrowerId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction =
                transactions[index].data() as Map<String, dynamic>;
            return TransactionCard(
              transaction: transaction,
              transactionId: transactions[index].id,
              isLenderView: false,
            );
          },
        );
      },
    );
  }
}

class _ActiveChatsTab extends StatelessWidget {
  final String userId;

  const _ActiveChatsTab({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;

        if (chats.isEmpty) {
          return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                 AppLocalizations.of(context)!.noactivechats,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data() as Map<String, dynamic>;
            final chatId = chats[index].id;
            List<String> participants = [];
            if (chat['participants'] != null) {
              participants = (chat['participants'] as List)
                  .map((item) => item.toString())
                  .toList();
            }

            // Find the other user's ID safely
            String? otherUserId;
            try {
              otherUserId = participants.firstWhere(
                (id) => id != userId,
                orElse: () => '',
              );
            } catch (e) {
              debugPrint('Error finding other user: $e');
            }

            // Skip this chat item if we can't find the other user
            if (otherUserId == null || otherUserId.isEmpty) {
              return const SizedBox.shrink();
            }

            return ChatListItem(
              chatId: chatId,
              otherUserId: otherUserId,
              lastMessage: chat['lastMessage'] ?? '',
              lastMessageTimestamp: chat['lastMessageTimestamp'],
              currentUserId: userId,
              offerId: chat['offerId'],
            );
          },
        );
      },
    );
  }
}

class MyOffersTab extends StatelessWidget {
  final String userId;

  const MyOffersTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookOffers')
          .where('offererId', isEqualTo: userId)
          .where('offerType', isEqualTo: 'DirectOffer')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final offers = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index].data() as Map<String, dynamic>;
            return OfferCard(
              offer: offer,
              offerId: offers[index].id,
              isLenderView: true,
            );
          },
        );
      },
    );
  }
}
class MyBookesTab extends StatelessWidget {
  final String userId;

  const MyBookesTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('available_books')
          .where('ownerId', isEqualTo: userId)
          // .where('offerType', isEqualTo: 'DirectOffer')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final myBookes = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: myBookes.length,
          itemBuilder: (context, index) {
            final bookes = myBookes[index].data() as Map<String, dynamic>;
            return MyBooksCard(
              myBookes: bookes,
     
            );
          },
        );
      },
    );
  }
}

class MyHistoryTab extends StatelessWidget {
  final String userId;

  const MyHistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('bookTransactions')
          .where('lenderId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .snapshots()
          .asyncMap((lenderSnapshot) async {
        // Get borrower transactions
        final borrowerSnapshot = await FirebaseFirestore.instance
            .collection('bookTransactions')
            .where('borrowerId', isEqualTo: userId)
            .orderBy('startDate', descending: true)
            .get();

        // Combine both results
        final allDocs = [
          ...lenderSnapshot.docs,
          ...borrowerSnapshot.docs,
        ];

        // Sort combined results by startDate
        allDocs.sort((a, b) {
          final dateA = (a.data()['startDate'] as Timestamp).toDate();
          final dateB = (b.data()['startDate'] as Timestamp).toDate();
          return dateB.compareTo(dateA); // descending order
        });

        return allDocs;
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

      final transactions = snapshot.data!;

        if (transactions.isEmpty) {
          return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                 AppLocalizations.of(context)!.nolendinghistoryyet,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                 AppLocalizations.of(context)!.booksyoulendwillappearhere,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction =
                transactions[index].data() as Map<String, dynamic>;
                  final isLenderView = transaction['lenderId'] == userId;
            return TransactionCard(
              transaction: transaction,
              transactionId: transactions[index].id,
                  isLenderView: isLenderView,
            );
          },
        );
      },
    );
  }
}
