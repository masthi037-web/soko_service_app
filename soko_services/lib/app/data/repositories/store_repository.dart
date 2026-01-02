import 'package:dio/dio.dart';
import '../../core/values/api_constants.dart';
import '../models/store_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class StoreRepository {
  final ApiService _apiService;
  CancelToken? _cancelToken;

  StoreRepository(this._apiService);

  Future<List<Category>> getCategories() async {
    // keeping mock
    return [
      Category(icon: '🥒', name: 'Pickle'),
      Category(icon: '🥛', name: 'Milk'),
      Category(icon: '🧀', name: 'Paneer'),
      Category(icon: '🧈', name: 'Ghee'),
      Category(icon: '👚', name: 'Ladies'),
      Category(icon: '👕', name: 'Mens'),
      Category(icon: '🎁', name: 'Gifts'),
    ];
  }

  Future<ApiResponse<List<Company>>> getStores() async {
    _cancelToken = CancelToken();
    final queryParameters = <String, dynamic>{};

    return await _apiService.getList<Company>(
      ApiConstants.companies,
      (json) => Company.fromJson(json),
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      cancelToken: _cancelToken,
    );
  }

  Future<List<Company>> getRecommendedStores() async {
    // Keep mock
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Company(
        companyId: 'rec1',
        companyName: 'The Clay Studio',
        companyProductCategory: 'Ceramics',
        companyCity: 'Portland',
        banner:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        logo:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        deliveryBetween: '3-5 days',
        averageRating: 4.9,
        companyCoupon: 'HOT',
        about:
            'Handcrafted, small-batch pottery made with locally sourced clay and organic glazes.',
        socialMediaLink: 'https://www.instagram.com',
      ),

      Company(
        companyId: 'rec2',
        companyName: 'Vibrant Candles',
        companyProductCategory: 'Home Decor',
        companyCity: 'Miami',
        banner:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        logo:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        deliveryBetween: '2-4 days',
        averageRating: 4.6,
        companyCoupon: 'SALE',
        about: 'Sustainable soy candles with unique scents inspired by nature.',
      ),
      Company(
        companyId: 'rec1',
        companyName: 'The Clay Studio',
        companyProductCategory: 'Ceramics',
        companyCity: 'Portland',
        banner:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        logo:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        deliveryBetween: '3-5 days',
        averageRating: 4.9,
        companyCoupon: 'HOT',
        about:
            'Handcrafted, small-batch pottery made with locally sourced clay and organic glazes.',
        socialMediaLink: 'https://www.instagram.com',
      ),

      Company(
        companyId: 'rec2',
        companyName: 'Vibrant Candles',
        companyProductCategory: 'Home Decor',
        companyCity: 'Miami',
        banner:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        logo:
            'https://images.pexels.com/photos/381739/pexels-photo-381739.jpeg',
        deliveryBetween: '2-4 days',
        averageRating: 4.6,
        companyCoupon: 'SALE',
        about: 'Sustainable soy candles with unique scents inspired by nature.',
      ),
    ];
  }
}
