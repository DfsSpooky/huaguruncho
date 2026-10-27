import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyAccessToken = 'jwt_access_token';
  static const String _keyRefreshToken = 'jwt_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyOnboardingDone = 'onboarding_completed_v2';
  static const String _keyWasteBagsCount = 'huella_cero_waste_bags_count';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> saveUserData({
    required int id,
    required String email,
    required String fullName,
    required String role,
  }) async {
    await _storage.write(key: _keyUserId, value: id.toString());
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: fullName);
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'id': await _storage.read(key: _keyUserId),
      'email': await _storage.read(key: _keyUserEmail),
      'full_name': await _storage.read(key: _keyUserName),
      'role': await _storage.read(key: _keyUserRole),
    };
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserRole);
  }

  Future<bool> hasCompletedOnboarding() async {
    final val = await _storage.read(key: _keyOnboardingDone);
    return val == 'true';
  }

  Future<void> setOnboardingCompleted([bool completed = true]) async {
    await _storage.write(key: _keyOnboardingDone, value: completed ? 'true' : 'false');
  }

  Future<int> getWasteBagsCount({int defaultValue = 4}) async {
    final val = await _storage.read(key: _keyWasteBagsCount);
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  Future<void> saveWasteBagsCount(int count) async {
    await _storage.write(key: _keyWasteBagsCount, value: count.toString());
  }
}
