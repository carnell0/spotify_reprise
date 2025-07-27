/// Base exception for the application
class AppException implements Exception {
  final String message;
  
  AppException({required this.message});
}

/// Server exception
class ServerException extends AppException {
  ServerException({required String message}) : super(message: message);
}

/// Authentication exception
class AuthException extends AppException {
  AuthException({required String message}) : super(message: message);
}

/// Cache exception
class CacheException extends AppException {
  CacheException({required String message}) : super(message: message);
}

/// Network exception
class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);
}