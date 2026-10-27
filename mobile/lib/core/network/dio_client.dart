import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient({required SecureStorageService storageService}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(storage: storageService, dio: dio),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }
}
