import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Typed failure returned by all API calls.
/// Never exposes raw exceptions to the UI layer.
class ApiFailure {
  const ApiFailure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNetworkError => statusCode == null;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiFailure($statusCode): $message';
}

/// Singleton Dio client configured for the Saabi AI backend.
/// Supabase calls use the official supabase_flutter client directly —
/// this client is ONLY for the external Saabi AI service.
class SaabiAiClient {
  SaabiAiClient._();
  static final SaabiAiClient instance = SaabiAiClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.saabiAiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (!AppConfig.isProduction) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[SaabiAI] $obj'),
      ));
    }

    return dio;
  }

  /// Maps a DioException to an [ApiFailure] with a user-friendly message.
  static ApiFailure handleError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return const ApiFailure(
            message: 'Connection timed out. Check your internet and try again.',
          );
        case DioExceptionType.connectionError:
          return const ApiFailure(
            message: 'Could not connect. Check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          return ApiFailure(
            message: 'Something went wrong on our end. Please try again.',
            statusCode: code,
          );
        default:
          return const ApiFailure(
            message: 'Something went wrong. Please try again.',
          );
      }
    }
    return const ApiFailure(message: 'An unexpected error occurred.');
  }
}
