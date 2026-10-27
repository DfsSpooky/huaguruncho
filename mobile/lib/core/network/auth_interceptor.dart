import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthInterceptor({
    required SecureStorageService storage,
    required Dio dio,
  })  : _storage = storage,
        _dio = dio;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await _dio.post(
            ApiEndpoints.refresh,
            data: {'refresh': refreshToken},
            options: Options(headers: {}),
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newAccess = refreshResponse.data['access'] as String;
            final newRefresh = refreshResponse.data['refresh'] as String? ?? refreshToken;
            await _storage.saveTokens(accessToken: newAccess, refreshToken: newRefresh);

            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccess';
            final cloneReq = await _dio.fetch(requestOptions);
            return handler.resolve(cloneReq);
          }
        } catch (_) {
          await _storage.clearSession();
        }
      }
    }
    handler.next(err);
  }
}
