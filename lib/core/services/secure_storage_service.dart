import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _masterKeyKey = 'master_key';
  static const String _masterPasswordHashKey = 'master_password_hash';

  /// Writes a value to secure storage
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a value from secure storage
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Deletes a value from secure storage
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Checks if the master key exists (i.e., user is onboarded)
  Future<bool> hasMasterKey() async {
    final key = await read(key: _masterKeyKey);
    return key != null;
  }
  
  /// Clears all storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
