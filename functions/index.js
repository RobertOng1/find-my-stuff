/**
 * Cloud Functions for FindMyStuff
 * 
 * Handles push notifications securely using Firebase Admin SDK.
 * No server keys in client code!
 * 
 * Triggers:
 * 1. onNewClaim - When a new claim document is created
 * 2. onClaimStatusUpdate - When claim status changes (accepted/rejected)
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// No credentials needed - automatically injected in Cloud Functions environment
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Trigger: When a new claim is created
 * Action: Send push notification to item owner
 */
exports.onNewClaim = functions.firestore
  .document("claims/{claimId}")
  .onCreate(async (snap, context) => {
    const claim = snap.data();
    const claimId = context.params.claimId;

    console.log(`New claim created: ${claimId}`);

    try {
      // Get item owner's FCM tokens
      const tokens = await getUserTokens(claim.finderId);

      if (tokens.length === 0) {
        console.log(`No FCM tokens found for user: ${claim.finderId}`);
        return null;
      }

      // Get item details for notification
      const itemDoc = await db.collection("posts").doc(claim.itemId).get();
      const itemName = itemDoc.exists ? itemDoc.data().title : "your item";

      // Send notification
      const message = {
        notification: {
          title: "🔔 New Claim Request!",
          body: `${claim.claimantName} wants to claim ${itemName}`,
        },
        data: {
          type: "NEW_CLAIM",
          claimId: claimId,
          itemId: claim.itemId,
          route: "/status",
        },
      };

      const response = await sendToMultipleTokens(tokens, message, claim.finderId);
      console.log(`Notification sent: ${response.successCount} success, ${response.failureCount} failure`);

      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });

/**
 * Trigger: When claim status is updated
 * Action: Send push notification to claimant
 */
exports.onClaimStatusUpdate = functions.firestore
  .document("claims/{claimId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const claimId = context.params.claimId;

    // Only trigger if status changed
    if (before.status === after.status) {
      return null;
    }

    console.log(`Claim status updated: ${claimId} - ${before.status} -> ${after.status}`);

    // Only notify for ACCEPTED or REJECTED
    if (after.status !== "ACCEPTED" && after.status !== "REJECTED") {
      return null;
    }

    try {
      // Get claimant's FCM tokens
      const tokens = await getUserTokens(after.claimantId);

      if (tokens.length === 0) {
        console.log(`No FCM tokens found for user: ${after.claimantId}`);
        return null;
      }

      // Get item details
      const itemDoc = await db.collection("posts").doc(after.itemId).get();
      const itemName = itemDoc.exists ? itemDoc.data().title : "your item";

      // Prepare notification based on status
      const isAccepted = after.status === "ACCEPTED";
      const message = {
        notification: {
          title: isAccepted ? "✅ Claim Accepted!" : "❌ Claim Rejected",
          body: isAccepted
            ? `Your claim for ${itemName} was accepted! Contact the finder to arrange pickup.`
            : `Your claim for ${itemName} was rejected.`,
        },
        data: {
          type: "CLAIM_UPDATE",
          claimId: claimId,
          status: after.status,
          route: "/status",
        },
      };

      const response = await sendToMultipleTokens(tokens, message, after.claimantId);
      console.log(`Notification sent: ${response.successCount} success, ${response.failureCount} failure`);

      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });

/**
 * Helper: Get all FCM tokens for a user
 * Supports multiple devices per user
 */
async function getUserTokens(userId) {
  const tokens = [];

  try {
    // Try subcollection first (multi-device support)
    const tokensSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("fcmTokens")
      .get();

    tokensSnapshot.forEach((doc) => {
      tokens.push(doc.id);
    });

    // Fallback to main document field
    if (tokens.length === 0) {
      const userDoc = await db.collection("users").doc(userId).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        tokens.push(userDoc.data().fcmToken);
      }
    }
  } catch (error) {
    console.error(`Error getting tokens for user ${userId}:`, error);
  }

  return tokens;
}

/**
 * Helper: Send notification to multiple tokens
 * Handles token cleanup for invalid tokens
 */
async function sendToMultipleTokens(tokens, message, userId) {
  if (tokens.length === 0) {
    return { successCount: 0, failureCount: 0 };
  }

  const response = await messaging.sendEachForMulticast({
    tokens: tokens,
    notification: message.notification,
    data: message.data,
    android: {
      priority: "high",
      notification: {
        sound: "default",
        channelId: "high_importance_channel",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  });

  // Clean up invalid tokens
  const tokensToRemove = [];
  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      const error = resp.error;
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        tokensToRemove.push(tokens[idx]);
      }
    }
  });

  // Remove invalid tokens from Firestore
  if (tokensToRemove.length > 0) {
    const batch = db.batch();
    tokensToRemove.forEach((token) => {
      const tokenRef = db
        .collection("users")
        .doc(userId)
        .collection("fcmTokens")
        .doc(token);
      batch.delete(tokenRef);
    });
    await batch.commit();
    console.log(`Removed ${tokensToRemove.length} invalid tokens`);
  }

  return response;
}
