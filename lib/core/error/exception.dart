class ServerException implements Exception {
  final String? msg;
  ServerException({this.msg});
}

class CacheException implements Exception {
  final String? msg;
  CacheException({this.msg});
}
