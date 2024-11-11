import 'package:bookes/resources/auth.dart';
import 'package:bookes/widgets/offerCard.dart';
import 'package:bookes/widgets/requestCard.dart';
import 'package:bookes/widgets/sliverAppBarDelegate.dart';
import 'package:bookes/widgets/transactionCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
                        await AuthMethods().signOut();
             Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'Sign Out',
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
                      tabs: const [
                        Tab(text: 'MY REQUESTS'),
                        Tab(text: 'OFFERS'),
                        Tab(text: 'HISTORY'),
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
                _OffersTab(userId: userId),
                _HistoryTab(userId: userId),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.yellow[700], size: 20),
              const SizedBox(width: 4),
              Text(
                '${userData['rating']?.toStringAsFixed(1) ?? '0.0'} (${userData['totalRatings'] ?? '0'})',
                style: const TextStyle(color: Colors.white),
              ),
            ],
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

class _OffersTab extends StatelessWidget {
  final String userId;

  const _OffersTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookOffers')
          .where('requesterId', isEqualTo: userId)
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
            );
          },
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final String userId;

  const _HistoryTab({Key? key, required this.userId}) : super(key: key);

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
            );
          },
        );
      },
    );
  }
}
