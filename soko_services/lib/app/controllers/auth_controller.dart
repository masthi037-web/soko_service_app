import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:soko_services/app/data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final _storage = GetStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Resend Logic
  int _resendAttempts = 0;
  DateTime? _blockTime;

  int get resendAttempts => _resendAttempts;
  bool get isBlocked {
    // if (_blockTime == null) return false;
    // if (DateTime.now().isAfter(_blockTime!)) {
    //   _resetResendLogic();
    //   return false;
    // }
    return false;
  }

  Duration get remainingBlockTime {
    if (_blockTime == null) return Duration.zero;
    final difference = _blockTime!.difference(DateTime.now());
    return difference.isNegative ? Duration.zero : difference;
  }

  AuthController(this._authRepository) {
    _loadResendState();
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
        _blockTime = DateTime.now().add(const Duration(minutes: 1));
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
        await _storage.write('accessToken', data['accessToken']);
        await _storage.write('refreshToken', data['refreshToken']);
        await _storage.write('role', data['role']);
        await _storage.write('isLoggedIn', true);
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
    await _storage.erase();
    notifyListeners();
  }

  bool get isLoggedIn => _storage.read('isLoggedIn') ?? false;
}
