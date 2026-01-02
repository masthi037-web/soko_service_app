import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soko_services/app/data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final _storage = GetStorage();
  final _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false; // Internal state request

  bool _isLoading =
      false; // Set true initially if you want to block UI until check is done
  bool get isLoading => _isLoading;

  // Resend Logic
  int _resendAttempts = 0;
  DateTime? _blockTime;

  int get resendAttempts => _resendAttempts;
  bool get isBlocked {
    if (_blockTime == null) return false;
    if (DateTime.now().isAfter(_blockTime!)) {
      _resetResendLogic();
      return false;
    }
    return false;
  }

  Duration get remainingBlockTime {
    if (_blockTime == null) return Duration.zero;
    final difference = _blockTime!.difference(DateTime.now());
    return difference.isNegative ? Duration.zero : difference;
  }

  AuthController(this._authRepository) {
    _loadResendState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedInString = await _secureStorage.read(key: 'isLoggedIn');
    _isLoggedIn = loggedInString == 'true';
    if (_isLoggedIn) {
      // Optional: Validate token expiry here if needed
      debugPrint('User is logged in');
    }
    notifyListeners();
  }

  void _loadResendState() {
    _resendAttempts = _storage.read('resendAttempts') ?? 0;
    final blockTimeStr = _storage.read('blockTime');
    if (blockTimeStr != null) {
      _blockTime = DateTime.parse(blockTimeStr);
    }
  }

  void _resetResendLogic() {
    _resendAttempts = 0;
    _blockTime = null;
    _storage.write('resendAttempts', 0);
    _storage.remove('blockTime');
    notifyListeners();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    if (phoneNumber.length != 10) {
      return false; // Basic validation check
    }

    if (isBlocked) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.sendOtp(phoneNumber);
      debugPrint('OTP Sent: ${response.toString()}');

      // Increment attempts
      _resendAttempts++;
      _storage.write('resendAttempts', _resendAttempts);

      if (_resendAttempts >= 3) {
        _blockTime = DateTime.now().add(const Duration(minutes: 5));
        _storage.write('blockTime', _blockTime!.toIso8601String());
      }

      return true;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.login(phone, otp);
      if (response.data != null) {
        final data = response.data!;
        // Securely store tokens and role
        await _secureStorage.write(
          key: 'accessToken',
          value: data['accessToken'],
        );
        await _secureStorage.write(
          key: 'refreshToken',
          value: data['refreshToken'],
        );
        await _secureStorage.write(key: 'role', value: data['role']);
        await _secureStorage.write(key: 'isLoggedIn', value: 'true');

        _isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    // Clear secure storage
    await _secureStorage.deleteAll();
    // Clear relevant GetStorage if needed (e.g. user preferences, but maybe keep resendAttempts)
    // _storage.erase(); // Be careful erasing all GetStorage if it holds other app data.

    // For now, let's keep _storage.erase() if that was the intent,
    // BUT usually we don't want to wipe resendAttempts on logout?
    // The previous code did `_storage.erase()`.
    // If we want to keep resend attempts persistent across logouts, we should NOT erase.
    // Assuming we just want to clear auth data:
    _isLoggedIn = false;
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;
}
