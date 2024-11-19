import 'package:bookes/resources/auth.dart';
import 'package:bookes/widgets/activeChatsTab.dart';
import 'package:bookes/widgets/combinedHistoryTab.dart';
import 'package:bookes/widgets/combinedOffersTab.dart';
import 'package:bookes/widgets/confirmDialog.dart';
import 'package:bookes/widgets/offerCard.dart';
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
            print('!userSnapshot.hasData');
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(userData),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        showLogoutConfirmation(context);

                        // await AuthMethods().signOut();
                        // Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child:  Text(
                        AppLocalizations.of(context)!.signout,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs:  [
                        Tab(text: AppLocalizations.of(context)!.myrequests),
                        Tab(text: AppLocalizations.of(context)!.offers),
                        Tab(text: AppLocalizations.of(context)!.history),
                        Tab(text: AppLocalizations.of(context)!.chats),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _RequestsTab(userId: userId),
                CombinedOffersTab(userId: userId),
                CombinedHistoryTab(userId: userId),
                _ActiveChatsTab(userId: userId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(height: 4),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Icon(Icons.star, color: Colors.yellow[700], size: 20),
          //     const SizedBox(width: 4),
          //     Text(
          //       '${userData['rating']?.toStringAsFixed(1) ?? '0.0'} (${userData['totalRatings'] ?? '0'})',
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //   ],
          // ),
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
    );
  }
}

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

class MyHistoryTab extends StatelessWidget {
  final String userId;

  const MyHistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookTransactions')
          .where('lenderId',
              isEqualTo: userId) // Changed from borrowerId to lenderId
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs;

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
            return TransactionCard(
              transaction: transaction,
              transactionId: transactions[index].id,
              isLenderView: true,
            );
          },
        );
      },
    );
  }
}
