import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio nestDio;
  late final Dio jellyfinDio;
  late final Dio lrclibDio;

  DioClient() {
    nestDio = _createNestDio();
    jellyfinDio = _createJellyfinDio();
    lrclibDio = _createLrclibDio();
  }

  Dio _createNestDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.nestBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(dio),
      PrettyDioLogger(
        requestBody: true,
        responseBody: false,
        error: true,
        compact: true,
      ),
    ]);

    return dio;
  }

  Dio _createJellyfinDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.jellyfinBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: false,
        responseBody: false,
        error: true,
        compact: true,
      ),
    );

    return dio;
  }

  Dio _createLrclibDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.lrclibBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for /auth/* endpoints
    if (!options.path.startsWith('/auth/')) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — could trigger refresh or logout here
    }
    handler.next(err);
  }
}

// API Error helper
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Check your network.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          message = data['message'] ?? 'Server error';
        } else {
          message = 'Server returned ${statusCode ?? 'unknown'} error';
        }
        break;
      default:
        message = e.message ?? 'An unexpected error occurred';
    }

    return ApiException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
