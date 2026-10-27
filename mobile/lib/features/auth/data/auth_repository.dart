import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storage;

  AuthRepository({
    required DioClient dioClient,
    required SecureStorageService storage,
  })  : _dioClient = dioClient,
        _storage = storage;

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final tokens = data['tokens'];

      await _storage.saveTokens(
        accessToken: tokens['access'],
        refreshToken: tokens['refresh'],
      );

      await _storage.saveUserData(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      );

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone ?? '',
        },
      );

      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final tokens = data['tokens'];

      await _storage.saveTokens(
        accessToken: tokens['access'],
        refreshToken: tokens['refresh'],
      );

      await _storage.saveUserData(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      );

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel?> getSavedUser() async {
    final data = await _storage.getUserData();
    if (data['id'] != null && data['email'] != null) {
      return UserModel(
        id: int.parse(data['id']!),
        email: data['email']!,
        fullName: data['full_name'] ?? '',
        role: data['role'] ?? 'turista',
      );
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.clearSession();
  }
}
