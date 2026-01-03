import 'package:flutter/material.dart';
import '../data/models/store_model.dart';
import '../data/services/wishlist_service.dart';

class WishlistController extends ChangeNotifier {
  final WishlistService _service;
  List<Company> _wishlistStores = [];

  WishlistController(this._service) {
    _loadWishlist();
  }

  List<Company> get wishlistStores => _wishlistStores;

  void _loadWishlist() {
    _wishlistStores = _service.getWishlistStores();
    notifyListeners();
  }

  bool isWishlisted(String? storeId) {
    if (storeId == null) return false;
    return _service.isWishlisted(storeId);
  }

  Future<void> toggleWishlist(Company store) async {
    if (store.companyId == null) return;

    if (isWishlisted(store.companyId)) {
      await _service.removeFromWishlist(store.companyId!);
    } else {
      await _service.addToWishlist(store);
    }
    _loadWishlist();
  }
}
