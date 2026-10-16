import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageDatasource {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureStorageDatasourceImpl implements SecureStorageDatasource {
  const SecureStorageDatasourceImpl([
    this._storage = const FlutterSecureStorage(),
  ]);

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
