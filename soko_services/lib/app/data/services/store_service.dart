import '../models/store_model.dart';
import '../models/category_model.dart';
import '../repositories/store_repository.dart';
import '../models/api_response.dart';

class StoreService {
  final StoreRepository _repository;

  StoreService(this._repository);

  Future<List<Category>> fetchCategories() {
    return _repository.getCategories();
  }

  Future<List<Company>> fetchStores() async {
    final response = await _repository.getStores();
    if (response.status == Status.success) {
      return response.data ?? [];
    }
    // Handle error state gracefully or rethrow.
    // For now, return empty to not break UI, or we can throw.
    return [];
  }

  Future<List<Company>> fetchRecommendedStores() {
    return _repository.getRecommendedStores();
  }
}
