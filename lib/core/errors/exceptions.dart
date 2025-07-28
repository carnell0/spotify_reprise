/// Base exception for the application
class AppException implements Exception {
  final String message;
  
  AppException({required this.message});
}

/// Server exception
class ServerException extends AppException {
  ServerException({required super.message});
}

/// Authentication exception
class AuthException extends AppException {
  AuthException({required super.message});
}

/// Cache exception
class CacheException extends AppException {
  CacheException({required super.message});
}

/// Network exception
class NetworkException extends AppException {
  NetworkException({required super.message});
}