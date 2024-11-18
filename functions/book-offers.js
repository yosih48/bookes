import * as functions from "firebase-functions";
import admin from "firebase-admin";

export const onBookOfferCreated = functions.firestore
  .document("bookOffers/{offerId}")
  .onCreate(async (snapshot, context) => {
    const bookOffer = snapshot.data();

    try {
      // Get requester's FCM token
      const requesterDoc = await admin
        .firestore()
        .collection("users")
        .doc(bookOffer.requesterId)
        .get();

      const requesterData = requesterDoc.data();
      const fcmToken = requesterData?.fcmToken;

      if (!fcmToken) {
        console.log("No FCM token found for user:", bookOffer.requesterId);
        return;
      }

      // Get the book request details
      const requestDoc = await admin
        .firestore()
        .collection("bookRequests")
        .doc(bookOffer.requestId)
        .get();

      const bookRequest = requestDoc.data();

      // Send notification
      const message = {
        notification: {
          title: "New Book Offer!",
          body: `Someone has offered the book "${bookRequest?.title}"!`,
        },
        data: {
          requestId: bookOffer.requestId,
          offerId: snapshot.id,
          type: "book_offer",
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log("Successfully sent notification to:", bookOffer.requesterId);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
