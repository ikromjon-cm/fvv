import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsService {
  static const _storage = FlutterSecureStorage();
  static const _keyEnabled = 'biometrics_enabled';
  static const _keyPhone = 'biometrics_phone';
  static const _keyPassword = 'biometrics_password';
  static const _keyRefreshToken = 'biometrics_refresh_token';
  static const _keyRole = 'biometrics_role';

  static Future<bool> isAvailable() async {
    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final isDevice = await localAuth.isDeviceSupported();
    return canCheck || isDevice;
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    final localAuth = LocalAuthentication();
    return localAuth.getAvailableBiometrics();
  }

  static Future<bool> authenticate({String? reason}) async {
    final localAuth = LocalAuthentication();
    try {
      return await localAuth.authenticate(
        localizedReason:
            reason ?? 'AVTORY ga kirish uchun barmoq izini skanerlang',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    try {
      final val = await _storage.read(key: _keyEnabled);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> setEnabled(bool value) async {
    await _storage.write(key: _keyEnabled, value: value.toString());
  }

  static Future<void> saveCredentials(
      String phone, String password, {String? refreshToken}) async {
    await _storage.write(key: _keyPhone, value: phone);
    await _storage.write(key: _keyPassword, value: password);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<Map<String, String>?> getCredentials() async {
    final phone = await _storage.read(key: _keyPhone);
    final password = await _storage.read(key: _keyPassword);
    if (phone == null || password == null) return null;
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    return {
      'phone': phone,
      'password': password,
      if (refreshToken != null) 'refresh_token': refreshToken,
    };
  }

  static Future<String?> getRole() async {
    return _storage.read(key: _keyRole);
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyEnabled);
    await _storage.delete(key: _keyRole);
  }
}
