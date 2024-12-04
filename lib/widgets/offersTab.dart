import 'package:bookes/widgets/offerCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OffersTab extends StatelessWidget {
  final String userId;

  const OffersTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(userId);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookOffers')
          .where('requesterId', isEqualTo: userId)
          .where('offerType', isEqualTo: 'DirectOffer')
          // .where('offerType', isEqualTo: 'AvailableOffer')
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
              isLenderView: false,
            );
          },
        );
      },
    );
  }
}
