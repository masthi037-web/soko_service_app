import 'package:hive_flutter/hive_flutter.dart';
import '../models/store_model.dart';

class WishlistService {
  static const String _boxName = 'wishlist_stores';
  static const int _expiryDays = 10;

  Future<void> init() async {
    // Box should be opened in main, but ensuring it's open here is safe
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Box get _box => Hive.box(_boxName);

  Future<void> addToWishlist(Company store) async {
    if (store.companyId == null) return;

    await _box.put(store.companyId, {
      'store': store.toJson(),
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFromWishlist(String storeId) async {
    await _box.delete(storeId);
  }

  bool isWishlisted(String storeId) {
    return _box.containsKey(storeId);
  }

  List<Company> getWishlistStores() {
    final List<Company> validStores = [];
    final List<dynamic> keysToRemove = [];
    final now = DateTime.now();

    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value is Map) {
        final int? addedAt = value['addedAt'];

        if (addedAt != null) {
          final addedDate = DateTime.fromMillisecondsSinceEpoch(addedAt);
          final difference = now.difference(addedDate).inDays;

          if (difference >= _expiryDays) {
            keysToRemove.add(key);
          } else {
            // Reconstruct Company object
            if (value['store'] != null) {
              // value['store'] comes as Map<dynamic, dynamic> from Hive, need to cast keys
              final Map<String, dynamic> storeMap = Map<String, dynamic>.from(
                value['store'],
              );
              validStores.add(Company.fromJson(storeMap));
            }
          }
        } else {
          // If no timestamp, assuming old or invalid, remove it?
          // Or keep it. Let's remove to be safe/clean.
          keysToRemove.add(key);
        }
      }
    }

    // Clean up expired items
    if (keysToRemove.isNotEmpty) {
      _box.deleteAll(keysToRemove);
    }

    return validStores;
  }
}
