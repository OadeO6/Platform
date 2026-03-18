import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

// ── Service providers ─────────────────────────────────────────────────────────

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

// ── Feed ──────────────────────────────────────────────────────────────────────

class FeedState {
  final List<ItemModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? selectedCategory;
  final String? searchQuery;
  final bool nearbyOnly;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.selectedCategory,
    this.searchQuery,
    this.nearbyOnly = false,
  });

  FeedState copyWith({
    List<ItemModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    bool? nearbyOnly,
  }) =>
      FeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        errorMessage: errorMessage,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
        nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      );
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FirestoreService _firestore;
  final String? _userId;
  final String? _userCity;

  FeedNotifier(this._firestore, this._userId, this._userCity)
      : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _firestore.getFeedItems(
        // Pass city for sorting; if nearbyOnly, filter to city only
        city: _userCity,
        nearbyOnly: state.nearbyOnly,
        category: state.selectedCategory,
        excludeSellerId: _userId,
      );
      if (!mounted) return;
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length >= AppConstants.feedPageSize,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> setCategory(String? category) async {
    state = state.copyWith(
      selectedCategory: category,
      items: [],
      hasMore: true,
    );
    await loadFeed();
  }

  Future<void> toggleNearby() async {
    state = state.copyWith(
      nearbyOnly: !state.nearbyOnly,
      items: [],
      hasMore: true,
    );
    await loadFeed();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchQuery: null);
      await loadFeed();
      return;
    }
    state = state.copyWith(isLoading: true, searchQuery: query);
    try {
      final items = await _firestore.searchItems(
        query: query,
        category: state.selectedCategory,
        excludeSellerId: _userId,
        city: state.nearbyOnly ? _userCity : null,
      );
      if (!mounted) return;
      state = state.copyWith(items: items, isLoading: false, hasMore: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => loadFeed();

  String? get userCity => _userCity;
}

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final user = ref.watch(currentUserValueProvider);
  return FeedNotifier(
    ref.watch(firestoreServiceProvider),
    userId,
    user?.city,
  );
});

// ── Item Detail ───────────────────────────────────────────────────────────────

/// Live stream of a single item — updates in real time.
final itemDetailProvider =
    StreamProvider.family<ItemModel?, String>((ref, itemId) {
  return ref.watch(firestoreServiceProvider).itemStream(itemId);
});

// ── My Space ──────────────────────────────────────────────────────────────────

/// Live stream of all items for the current user.
final mySpaceProvider = StreamProvider<List<ItemModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).mySpaceStream(userId);
});

/// Listed items only
final listedItemsProvider = Provider<List<ItemModel>>((ref) {
  final items = ref.watch(mySpaceProvider).value ?? [];
  return items.where((i) => i.isActive && !i.isExpired).toList();
});

/// Unlisted items only (includes expired active items)
final unlistedItemsProvider = Provider<List<ItemModel>>((ref) {
  final items = ref.watch(mySpaceProvider).value ?? [];
  return items.where((i) => i.isUnlisted || (i.isActive && i.isExpired)).toList();
});

/// Sold items only
final soldItemsProvider = Provider<List<ItemModel>>((ref) {
  final items = ref.watch(mySpaceProvider).value ?? [];
  return items.where((i) => i.isSold).toList();
});

// ── Item Actions Notifier ─────────────────────────────────────────────────────

class ItemActionState {
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  const ItemActionState({
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  ItemActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) =>
      ItemActionState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        success: success ?? this.success,
      );
}

class ItemActionNotifier extends StateNotifier<ItemActionState> {
  final FirestoreService _firestore;
  final StorageService _storage;

  ItemActionNotifier(this._firestore, this._storage)
      : super(const ItemActionState());

  /// Creates a new item in Firestore with uploaded images.
  /// Images are uploaded to Cloudinary first, then item saved to Firestore.
  Future<String?> createItem({
    required String title,
    required double price,
    required bool priceNegotiable,
    required String category,
    required String condition,
    String? description,
    required List<File> images,
    File? receiptImage,
    required String sellerId,
    required String sellerName,
    String? whatsappContact,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Upload images to Cloudinary
      final imageUrls = await _storage.uploadItemImages(images);
      String? receiptUrl;
      if (receiptImage != null) {
        receiptUrl = await _storage.uploadItemImage(receiptImage);
      }

      // Build item model (saved as unlisted first)
      final item = ItemModel(
        id: const Uuid().v4(), // Temp ID — replaced by Firestore
        title: title,
        price: price,
        priceNegotiable: priceNegotiable,
        category: category,
        condition: condition,
        description: description,
        imageUrls: imageUrls,
        receiptImageUrl: receiptUrl,
        status: AppConstants.statusUnlisted,
        sellerId: sellerId,
        sellerName: sellerName,
        whatsappContact: whatsappContact ?? '',
        city: city,
        area: area,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final itemId = await _firestore.createItem(item);
      state = state.copyWith(isLoading: false, success: true);
      return itemId;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Updates an existing item's editable fields.
  Future<bool> updateItem(
    String itemId, {
    double? price,
    bool? priceNegotiable,
    String? category,
    String? condition,
    String? description,
    List<File>? newImages,
    List<String>? existingImageUrls,
    File? receiptImage,
    String? existingReceiptUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updates = <String, dynamic>{};

      if (price != null) updates['price'] = price;
      if (priceNegotiable != null) {
        updates['price_negotiable'] = priceNegotiable;
      }
      if (category != null) updates['category'] = category;
      if (condition != null) updates['condition'] = condition;
      updates['description'] = description;

      // Handle images — upload new ones, keep existing URLs
      if (newImages != null) {
        final newUrls = await _storage.uploadItemImages(newImages);
        final allUrls = [...(existingImageUrls ?? []), ...newUrls];
        updates['image_urls'] = allUrls;
      } else if (existingImageUrls != null) {
        updates['image_urls'] = existingImageUrls;
      }

      // Handle receipt
      if (receiptImage != null) {
        final receiptUrl = await _storage.uploadItemImage(receiptImage);
        updates['receipt_image_url'] = receiptUrl;
      } else {
        updates['receipt_image_url'] = existingReceiptUrl;
      }

      await _firestore.updateItem(itemId, updates);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Lists an item — validates caps and contact info first.
  Future<bool> listItem(
    ItemModel item, {
    required int currentListingCount,
    required String userId,
    String? contactInfo,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (currentListingCount >= AppConstants.listingCap) {
        throw const ListingCapException();
      }

      // Ensure we have a WhatsApp number
      final currentWhatsApp = contactInfo ?? item.whatsappContact;
      if (currentWhatsApp.trim().isEmpty) {
        throw const DatabaseException(
            'A WhatsApp number is required to list items. Please update your profile.');
      }

      // If the number on the item is different from the provided one (e.g. user just updated profile),
      // update the item document first.
      if (contactInfo != null && contactInfo != item.whatsappContact) {
        await _firestore.updateItem(item.id, {'whatsapp_contact': contactInfo});
      }

      await _firestore.listItem(item.id);
      await _firestore.updateListingCount(userId, delta: 1);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Unlists an item.
  Future<bool> unlistItem(ItemModel item, {required String userId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestore.unlistItem(item.id);
      await _firestore.updateListingCount(userId, delta: -1);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Marks an item as sold.
  Future<bool> markAsSold(String itemId, String sellerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestore.markAsSold(itemId, sellerId);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Deletes an item permanently.
  Future<bool> deleteItem(
    ItemModel item, {
    required String sellerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestore.deleteItem(
        item.id,
        sellerId,
        wasActive: item.isActive,
      );
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Reports a listing.
  Future<bool> reportItem({
    required String itemId,
    required String reporterId,
    required String reason,
    String? details,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final report = ReportModel(
        id: '',
        itemId: itemId,
        reporterId: reporterId,
        reason: reason,
        details: details,
        createdAt: DateTime.now(),
      );
      await _firestore.reportItem(report);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() => state = const ItemActionState();
}

final itemActionNotifierProvider =
    StateNotifierProvider<ItemActionNotifier, ItemActionState>((ref) {
  return ItemActionNotifier(
    ref.watch(firestoreServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
