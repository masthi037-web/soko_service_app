import 'package:flutter/material.dart';
import '../data/models/store_model.dart';
import '../data/models/category_model.dart';
import '../data/services/store_service.dart';

enum SortOption { defaultSort, newArrivals, rating, deliveryTime }

enum OfferOption { freeShipping, discounts }

class HomeController extends ChangeNotifier {
  final StoreService _storeService;

  List<Category> _categories = [];
  List<Company> _stores = [];
  List<Company> _filteredStores = [];
  List<Company> _recommendedStores = [];
  bool _isLoading = false;

  HomeController(this._storeService);

  List<Category> get categories => _categories;
  List<Company> get stores => _stores;
  List<Company> get filteredStores => _filteredStores;
  List<Company> get recommendedStores => _recommendedStores;
  bool get isLoading => _isLoading;

  SortOption _selectedSort = SortOption.defaultSort;
  Set<OfferOption> _selectedOffers = {};
  double? _minRating;

  SortOption get selectedSort => _selectedSort;
  Set<OfferOption> get selectedOffers => _selectedOffers;
  double? get minRating => _minRating;

  bool get hasActiveFilters =>
      _selectedSort != SortOption.defaultSort ||
      _selectedOffers.isNotEmpty ||
      _minRating != null;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _storeService.fetchCategories(),
        _storeService.fetchStores(),
        _storeService.fetchRecommendedStores(),
      ]);

      _categories = results[0] as List<Category>;
      _stores = results[1] as List<Company>;
      _filteredStores = List.from(_stores); // Initialize filtered list
      _recommendedStores = results[2] as List<Company>;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchStores(String query) {
    if (query.isEmpty) {
      _filteredStores = List.from(_stores);
    } else {
      _filteredStores = _stores
          .where(
            (store) =>
                store.companyName != null &&
                store.companyName!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  List<Company> getSuggestions(String query) {
    if (query.isEmpty) {
      return const [];
    }
    return _stores
        .where(
          (store) =>
              store.companyName != null &&
              store.companyName!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  void applyFilters({
    required SortOption sort,
    required Set<OfferOption> offers,
    double? minRating,
  }) {
    _selectedSort = sort;
    _selectedOffers = offers;
    _minRating = minRating;
    _applyFiltersInternal();
    notifyListeners();
  }

  void clearFilters() {
    _selectedSort = SortOption.defaultSort;
    _selectedOffers = {};
    _minRating = null;
    _filteredStores = List.from(_stores);
    notifyListeners();
  }

  void resetSort() {
    _selectedSort = SortOption.defaultSort;
    _applyFiltersInternal();
    notifyListeners();
  }

  void removeOfferFilter(OfferOption offer) {
    _selectedOffers.remove(offer);
    _applyFiltersInternal();
    notifyListeners();
  }

  void removeRatingFilter() {
    _minRating = null;
    _applyFiltersInternal();
    notifyListeners();
  }

  void _applyFiltersInternal() {
    // 1. Filter by Rating & Offers
    var tempStores = _stores.where((store) {
      if (_selectedSort == SortOption.newArrivals) {
        if (store.companyRegisteredAt == null) {
          return false;
        }
        try {
          final registeredDate = DateTime.parse(store.companyRegisteredAt!);
          final diff = DateTime.now().difference(registeredDate).inHours;
          if (diff > 1) {
            return false; // Only show stores registered within 1 hour
          }
        } catch (e) {
          return false;
        }
      }

      // Rating Filter
      if (_minRating != null) {
        if ((store.averageRating ?? 0) < _minRating!) return false;
      }

      // Offers Filter
      if (_selectedOffers.contains(OfferOption.freeShipping)) {
        if (store.freeDeliveryCost == null || store.freeDeliveryCost!.isEmpty) {
          return false;
        }
      }
      if (_selectedOffers.contains(OfferOption.discounts)) {
        if (store.companyCoupon == null || store.companyCoupon!.isEmpty) {
          return false;
        }
      }
      return true;
    }).toList();

    // 2. Sort
    switch (_selectedSort) {
      case SortOption.rating:
        tempStores.sort(
          (a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0),
        );
        break;
      case SortOption.deliveryTime:
        tempStores.sort((a, b) {
          return _parseDeliveryTime(
            a.deliveryBetween,
          ).compareTo(_parseDeliveryTime(b.deliveryBetween));
        });
        break;
      case SortOption.newArrivals:
        // Already filtered to show only new ones, now sort by date (newest first)
        tempStores.sort((a, b) {
          return (b.companyRegisteredAt ?? '').compareTo(
            a.companyRegisteredAt ?? '',
          );
        });
        break;
      case SortOption.defaultSort:
        // No Sorting - keep processed order (which is essentially random after filtering)
        // OR restore original relative order of the filtered items
        // For simplicity and stability, we can sort by original index or name if needed,
        // but here we just leave them as they came out of the filter (often preserving relative order).
        break;
    }

    _filteredStores = tempStores;
  }

  int _parseDeliveryTime(String? deliveryString) {
    if (deliveryString == null) return 999;
    final match = RegExp(r'\d+').firstMatch(deliveryString);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 999;
  }
}
