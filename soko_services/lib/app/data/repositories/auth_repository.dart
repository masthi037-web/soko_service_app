import '../services/api_service.dart';
import '../../core/values/api_constants.dart';
import '../models/api_response.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<ApiResponse<String>> sendOtp(String phoneNumber) async {
    return _apiService.post<String>(
      ApiConstants.sendOtp,
      (data) => data.toString(),
      queryParameters: {'phone': phoneNumber},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login(
    String phone,
    String otp,
  ) async {
    return _apiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      (data) => data as Map<String, dynamic>,
      data: {'phone': phone, 'otp': otp},
    );
  }
}
