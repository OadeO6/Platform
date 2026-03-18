import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Live stream of saved item IDs for the current user.
final savedItemIdsProvider = StreamProvider<List<String>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).savedItemIdsStream(userId);
});

/// Returns true if a specific item is saved by the current user.
final isItemSavedProvider = Provider.family<bool, String>((ref, itemId) {
  final savedIds = ref.watch(savedItemIdsProvider).value ?? [];
  return savedIds.contains(itemId);
});

/// Full saved items list with details fetched.
final savedItemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  final savedIds = ref.watch(savedItemIdsProvider).value ?? [];
  if (savedIds.isEmpty) return [];
  return ref.watch(firestoreServiceProvider).getSavedItems(savedIds);
});

// ── Save/unsave actions ───────────────────────────────────────────────────────

class SavedNotifier extends StateNotifier<bool> {
  final FirestoreService _firestore;
  final String _userId;

  SavedNotifier(this._firestore, this._userId) : super(false);

  Future<void> toggleSave(String itemId, {required bool currentlySaved}) async {
    try {
      if (currentlySaved) {
        await _firestore.unsaveItem(_userId, itemId);
      } else {
        await _firestore.saveItem(_userId, itemId);
      }
    } catch (e) {
      // Silently fail — UI will revert via stream
    }
  }
}

final savedNotifierProvider =
    StateNotifierProvider<SavedNotifier, bool>((ref) {
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return SavedNotifier(ref.watch(firestoreServiceProvider), userId);
});
