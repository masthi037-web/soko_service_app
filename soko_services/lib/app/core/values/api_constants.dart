class ApiConstants {
  static const String baseUrl = 'http://localhost:8080/api/v1/rurify-services';
  static const String androidBaseUrl =
      'http://10.0.2.2:8080/api/v1/rurify-services';
  static const String companies = '/company/get/companies';
  static const String sendOtp = '/auth/send-otp';
  static const String login = '/auth/login';

  static const int connectTimeoutMs = 5000;
  static const int receiveTimeoutMs = 3000;
  static const int sendTimeoutMs = 3000;

  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String acceptLanguage = 'Accept-Language';
}
