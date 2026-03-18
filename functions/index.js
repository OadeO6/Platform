const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentDeleted } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

const db = getFirestore();
const fcm = getMessaging();

// ── Constants ──────────────────────────────────────────────────────────────────

const WARN_DAYS = 3;         // Days before expiry to send warning
const NOTIF_TYPE_EXPIRY = 'listing_expiry';

// ── Expiry Warning — runs every day at 9:00 AM WAT (UTC+1 = 08:00 UTC) ────────

exports.sendExpiryWarnings = onSchedule(
  {
    schedule: '0 8 * * *',   // 08:00 UTC = 09:00 WAT daily
    timeZone: 'UTC',
    region: 'us-central1',
  },
  async () => {
    const now = new Date();
    const warnCutoff = new Date(now);
    warnCutoff.setDate(warnCutoff.getDate() + WARN_DAYS);

    // Find all active items expiring within the next WARN_DAYS days
    const snapshot = await db.collection('items')
      .where('status', '==', 'active')
      .where('expires_at', '>', Timestamp.fromDate(now))
      .where('expires_at', '<=', Timestamp.fromDate(warnCutoff))
      .get();

    if (snapshot.empty) {
      console.log('No items expiring soon.');
      return;
    }

    console.log(`Found ${snapshot.size} items expiring within ${WARN_DAYS} days.`);

    const promises = snapshot.docs.map(async (doc) => {
      const item = doc.data();
      const sellerId = item.seller_id;
      const itemId = doc.id;
      const title = item.title;

      if (!sellerId) return;

      // Get seller's FCM token
      const userDoc = await db.collection('users').doc(sellerId).get();
      if (!userDoc.exists) return;

      const fcmToken = userDoc.data().fcm_token;
      if (!fcmToken) return;

      // Calculate days remaining
      const expiresAt = item.expires_at.toDate();
      const msRemaining = expiresAt - now;
      const daysRemaining = Math.ceil(msRemaining / (1000 * 60 * 60 * 24));
      const dayLabel = daysRemaining === 1 ? '1 day' : `${daysRemaining} days`;

      // Build FCM message
      const message = {
        token: fcmToken,
        notification: {
          title: 'Listing expiring soon',
          body: `"${title}" expires in ${dayLabel}. Relist it to keep it visible.`,
        },
        data: {
          type: NOTIF_TYPE_EXPIRY,
          item_id: itemId,
        },
        android: {
          notification: {
            channelId: 'platform_expiry',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      try {
        await fcm.send(message);
        console.log(`Sent expiry warning for item ${itemId} to user ${sellerId}`);
      } catch (err) {
        // Token may be stale — log but don't throw
        console.error(`Failed to send to ${sellerId}:`, err.message);

        // Clean up invalid token
        if (
          err.code === 'messaging/registration-token-not-registered' ||
          err.code === 'messaging/invalid-registration-token'
        ) {
          await db.collection('users').doc(sellerId).update({
            fcm_token: null,
          });
        }
      }
    });

    await Promise.allSettled(promises);
    console.log('Expiry warning run complete.');
  }
);

// ── Auto-expire listings — runs every hour ─────────────────────────────────────
// Marks active items as unlisted once they've passed their expiry date.

exports.expireListings = onSchedule(
  {
    schedule: 'every 60 minutes',
    region: 'us-central1',
  },
  async () => {
    const now = Timestamp.now();

    const snapshot = await db.collection('items')
      .where('status', '==', 'active')
      .where('expires_at', '<', now)
      .limit(100) // Process in batches
      .get();

    if (snapshot.empty) {
      console.log('No expired listings to process.');
      return;
    }

    console.log(`Expiring ${snapshot.size} listings.`);

    const batch = db.batch();
    const sellerDecrements = {};

    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, { status: 'unlisted' });
      const sellerId = doc.data().seller_id;
      if (sellerId) {
        sellerDecrements[sellerId] =
          (sellerDecrements[sellerId] || 0) + 1;
      }
    });

    await batch.commit();

    // Decrement listing counts for affected sellers
    const sellerUpdates = Object.entries(sellerDecrements).map(
      ([sellerId, count]) =>
        db.collection('users').doc(sellerId).update({
          listing_count: require('firebase-admin/firestore')
            .FieldValue.increment(-count),
        })
    );
    await Promise.allSettled(sellerUpdates);

    console.log('Expire listings run complete.');
  }
);

// ── Clean up saved items when an item is deleted ───────────────────────────────
// When an item document is deleted, remove it from all users' saved collections.

exports.cleanupSavedOnItemDelete = onDocumentDeleted(
  {
    document: 'items/{itemId}',
    region: 'us-central1',
  },
  async (event) => {
    const itemId = event.params.itemId;

    // Find all users who saved this item
    const savedQuery = await db.collectionGroup('saved')
      .where('item_id', '==', itemId)
      .get();

    if (savedQuery.empty) return;

    const batch = db.batch();
    savedQuery.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    console.log(
      `Cleaned up ${savedQuery.size} saved references for deleted item ${itemId}`
    );
  }
);
