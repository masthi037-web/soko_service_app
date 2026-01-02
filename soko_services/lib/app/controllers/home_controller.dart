import 'package:flutter/material.dart';
import '../data/models/store_model.dart';
import '../data/models/category_model.dart';
import '../data/services/store_service.dart';

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
}
