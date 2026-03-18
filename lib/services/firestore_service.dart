import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

/// Handles all Firestore reads and writes for Platform.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(AppConstants.colUsers);

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection(AppConstants.colItems);

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection(AppConstants.colReports);

  DocumentReference<Map<String, dynamic>> _savedRef(
          String userId, String itemId) =>
      _users
          .doc(userId)
          .collection(AppConstants.colSaved)
          .doc(itemId);

  CollectionReference<Map<String, dynamic>> _savedCollection(String userId) =>
      _users.doc(userId).collection(AppConstants.colSaved);

  // ── Users ─────────────────────────────────────────────────────────────────

  /// Creates or updates a user document.
  Future<void> setUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save user: $e');
    }
  }

  /// Fetches a user by ID. Returns null if not found.
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw DatabaseException('Failed to fetch user: $e');
    }
  }

  /// Stream of a user document — live updates.
  Stream<UserModel?> userStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Updates specific user fields.
  Future<void> updateUser(String userId, Map<String, dynamic> fields) async {
    try {
      await _users.doc(userId).update(fields);
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }

  /// Updates the user's FCM token.
  Future<void> updateFcmToken(String userId, String token) async {
    await _users.doc(userId).update({'fcm_token': token});
  }

  /// Deletes a user document and all their items.
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete all items by this user
      final items = await _items
          .where('seller_id', isEqualTo: userId)
          .get();
      final batch = _db.batch();
      for (final doc in items.docs) {
        batch.delete(doc.reference);
      }
      // Delete saved subcollection
      final saved = await _savedCollection(userId).get();
      for (final doc in saved.docs) {
        batch.delete(doc.reference);
      }
      // Delete user document
      batch.delete(_users.doc(userId));
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to delete user data: $e');
    }
  }

  // ── Items — Feed ──────────────────────────────────────────────────────────

  /// Fetches paginated active feed items.
  /// Same-city items first (newest), then all others (newest).
  Future<List<ItemModel>> getFeedItems({
  String? city,
  bool nearbyOnly = false,
  String? category,
  String? excludeSellerId,
  DocumentSnapshot? lastDocument,
  int limit = AppConstants.feedPageSize,
}) async {
  try {
    Query<Map<String, dynamic>> query = _items
        .where('status', isEqualTo: AppConstants.statusActive)
        .where('expires_at', isGreaterThan: Timestamp.now())
        .orderBy('expires_at')           // ← required when using range on expires_at
        .orderBy('listed_at', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    if (nearbyOnly && city != null) {
      query = query.where('city', isEqualTo: city);
    }

    // Fetch a slightly larger batch to account for filtering out own items
    query = query.limit(limit + 5);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    var items = snapshot.docs.map(ItemModel.fromFirestore).toList();

    // Filter out own items client-side
    if (excludeSellerId != null) {
      items = items.where((i) => i.sellerId != excludeSellerId).toList();
    }

    // Sort: same-city first
    if (!nearbyOnly && city != null) {
      final sameCity = items.where((i) => i.city == city).toList();
      final others = items.where((i) => i.city != city).toList();
      items = [...sameCity, ...others];
    }

    return items.take(limit).toList();
  } catch (e) {
    throw DatabaseException('Failed to fetch feed: $e');
  }
}

  /// Searches feed items by title (client-side prefix match).
  Future<List<ItemModel>> searchItems({
    required String query,
    String? category,
    String? excludeSellerId,
    String? city,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _items
          .where('status', isEqualTo: AppConstants.statusActive)
          .where('expires_at', isGreaterThan: Timestamp.now())
          .orderBy('listed_at', descending: true)
          .limit(100);

      if (category != null && category != 'All') {
        firestoreQuery =
            firestoreQuery.where('category', isEqualTo: category);
      }

      final snapshot = await firestoreQuery.get();
      final items = snapshot.docs.map(ItemModel.fromFirestore).toList();

      // Client-side title filter + optional city filter
      final lowerQuery = query.toLowerCase();
      return items
          .where((item) =>
              item.title.toLowerCase().contains(lowerQuery) &&
              item.sellerId != excludeSellerId &&
              (city == null || item.city == city))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to search items: $e');
    }
  }

  // ── Items — Single ────────────────────────────────────────────────────────

  /// Fetches a single item by ID.
  Future<ItemModel?> getItem(String itemId) async {
    try {
      final doc = await _items.doc(itemId).get();
      if (!doc.exists) return null;
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw DatabaseException('Failed to fetch item: $e');
    }
  }

  /// Stream of a single item — live updates.
  Stream<ItemModel?> itemStream(String itemId) {
    return _items.doc(itemId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ItemModel.fromFirestore(doc);
    });
  }

  // ── Items — My Space ──────────────────────────────────────────────────────

  /// Fetches all items for a seller (active + unlisted + sold).
  Stream<List<ItemModel>> mySpaceStream(String sellerId) {
    return _items
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ItemModel.fromFirestore).toList());
  }

  /// Fetches public active listings for a seller profile.
  Future<List<ItemModel>> getSellerListings(String sellerId) async {
    try {
      final snapshot = await _items
          .where('seller_id', isEqualTo: sellerId)
          .where('status', isEqualTo: AppConstants.statusActive)
          .where('expires_at', isGreaterThan: Timestamp.now())
          .orderBy('listed_at', descending: true)
          .get();
      return snapshot.docs.map(ItemModel.fromFirestore).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch seller listings: $e');
    }
  }

  // ── Items — Write ─────────────────────────────────────────────────────────

  /// Creates a new item. Returns the new item ID.
  Future<String> createItem(ItemModel item) async {
    try {
      final ref = _items.doc();
      final newItem = ItemModel(
        id: ref.id,
        title: item.title,
        price: item.price,
        priceNegotiable: item.priceNegotiable,
        category: item.category,
        condition: item.condition,
        description: item.description,
        imageUrls: item.imageUrls,
        receiptImageUrl: item.receiptImageUrl,
        status: item.status,
        sellerId: item.sellerId,
        sellerName: item.sellerName,
        whatsappContact: item.whatsappContact,
        city: item.city,
        area: item.area,
        latitude: item.latitude,
        longitude: item.longitude,
        saveCount: 0,
        isPopular: false,
        edited: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        listedAt: item.listedAt,
        expiresAt: item.expiresAt,
      );
      await ref.set(newItem.toMap());

      // Increment user's space count
      await _users.doc(item.sellerId).update({
        'space_count': FieldValue.increment(1),
      });

      return ref.id;
    } catch (e) {
      throw DatabaseException('Failed to create item: $e');
    }
  }

  /// Updates an existing item.
  Future<void> updateItem(String itemId, Map<String, dynamic> fields) async {
    try {
      await _items.doc(itemId).update({
        ...fields,
        'updated_at': Timestamp.now(),
        'edited': true,
      });
    } catch (e) {
      throw DatabaseException('Failed to update item: $e');
    }
  }

  /// Lists an item — sets status to active, sets listed_at and expires_at.
  Future<void> listItem(String itemId) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: AppConstants.expiryDays));
      await _items.doc(itemId).update({
        'status': AppConstants.statusActive,
        'listed_at': Timestamp.fromDate(now),
        'expires_at': Timestamp.fromDate(expiresAt),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw DatabaseException('Failed to list item: $e');
    }
  }

  /// Unlists an item — sets status to unlisted.
  Future<void> unlistItem(String itemId) async {
    try {
      await _items.doc(itemId).update({
        'status': AppConstants.statusUnlisted,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw DatabaseException('Failed to unlist item: $e');
    }
  }

  /// Marks an item as sold.
  Future<void> markAsSold(String itemId, String sellerId) async {
    try {
      final batch = _db.batch();
      batch.update(_items.doc(itemId), {
        'status': AppConstants.statusSold,
        'updated_at': Timestamp.now(),
      });
      // Decrement listing count, decrement space count
      batch.update(_users.doc(sellerId), {
        'listing_count': FieldValue.increment(-1),
        'space_count': FieldValue.increment(-1),
      });
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to mark item as sold: $e');
    }
  }

  /// Deletes an item permanently.
  Future<void> deleteItem(String itemId, String sellerId,
      {required bool wasActive}) async {
    try {
      final batch = _db.batch();
      batch.delete(_items.doc(itemId));
      // Always decrement space count; decrement listing count only if was active
      final updates = <String, dynamic>{
        'space_count': FieldValue.increment(-1),
      };
      if (wasActive) {
        updates['listing_count'] = FieldValue.increment(-1);
      }
      batch.update(_users.doc(sellerId), updates);
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to delete item: $e');
    }
  }

  /// Updates listing and space counters when item status changes.
  Future<void> updateListingCount(String userId,
      {required int delta}) async {
    await _users.doc(userId).update({
      'listing_count': FieldValue.increment(delta),
    });
  }

  // ── Saved ─────────────────────────────────────────────────────────────────

  /// Saves an item for a user.
  Future<void> saveItem(String userId, String itemId) async {
    try {
      await _savedRef(userId, itemId).set({
        'item_id': itemId,
        'saved_at': Timestamp.now(),
      });
      // Increment save count on item
      await _items.doc(itemId).update({
        'save_count': FieldValue.increment(1),
      });
      // Update popular flag if threshold reached
      final item = await getItem(itemId);
      if (item != null &&
          item.saveCount + 1 >= AppConstants.popularThreshold &&
          !item.isPopular) {
        await _items.doc(itemId).update({'is_popular': true});
      }
    } catch (e) {
      throw DatabaseException('Failed to save item: $e');
    }
  }

  /// Removes a saved item for a user.
  Future<void> unsaveItem(String userId, String itemId) async {
    try {
      await _savedRef(userId, itemId).delete();
      await _items.doc(itemId).update({
        'save_count': FieldValue.increment(-1),
      });
    } catch (e) {
      throw DatabaseException('Failed to unsave item: $e');
    }
  }

  /// Returns true if the user has saved a specific item.
  Future<bool> isItemSaved(String userId, String itemId) async {
    final doc = await _savedRef(userId, itemId).get();
    return doc.exists;
  }

  /// Stream of all saved item IDs for a user.
  Stream<List<String>> savedItemIdsStream(String userId) {
    return _savedCollection(userId)
        .orderBy('saved_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// Fetches full item details for a list of saved item IDs.
  Future<List<ItemModel>> getSavedItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return [];
    try {
      final futures = itemIds.map((id) => getItem(id));
      final results = await Future.wait(futures);
      return results.whereType<ItemModel>().toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch saved items: $e');
    }
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  /// Submits a report for a listing.
  Future<void> reportItem(ReportModel report) async {
    try {
      // Check if user already reported this item
      final existing = await _reports
          .where('item_id', isEqualTo: report.itemId)
          .where('reporter_id', isEqualTo: report.reporterId)
          .get();
      if (existing.docs.isNotEmpty) {
        throw const DatabaseException('You have already reported this listing.');
      }
      await _reports.add(report.toMap());
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException('Failed to submit report: $e');
    }
  }
}
