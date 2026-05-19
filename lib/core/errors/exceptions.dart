class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
}

class NativeException implements Exception {
  final String message;
  NativeException(this.message);
}
