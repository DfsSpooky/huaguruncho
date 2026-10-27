import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de espera agotado. Verifica tu conexión a internet.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Error del servidor ($status).';

        if (data is Map) {
          if (data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data.containsKey('detail')) {
            message = data['detail'].toString();
          } else if (data.containsKey('errors')) {
            message = data['errors'].toString();
          }
        }

        return ApiException(
          message: message,
          statusCode: status,
          data: data,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No se pudo conectar con el servidor. Modo offline activado.',
          statusCode: null,
        );
      default:
        return ApiException(
          message: error.message ?? 'Ocurrió un error inesperado de red.',
          statusCode: error.response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
