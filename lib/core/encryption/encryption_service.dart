import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

abstract class EncryptionService {
  Future<SecretKey> deriveKey(String password, List<int> salt);
  Future<List<int>> encrypt(String plainText, SecretKey key);
  Future<String> decrypt(List<int> data, SecretKey key);
}

class EncryptionServiceImpl implements EncryptionService {
  final _algorithm = AesGcm.with256bits();
  final _kdf = Argon2id(
    parallelism: 1,
    memory: 4096, // 4 MB - Faster for UI response
    iterations: 1,
    hashLength: 32, // 256 bits
  );

  @override
  Future<SecretKey> deriveKey(String password, List<int> salt) async {
    final secretKey = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return secretKey;
  }

  @override
  Future<List<int>> encrypt(String plainText, SecretKey key) async {
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
    );
    return secretBox.concatenation();
  }

  @override
  Future<String> decrypt(List<int> data, SecretKey key) async {
    final secretBox = SecretBox.fromConcatenation(
      data,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );

    final clearText = await _algorithm.decrypt(
      secretBox,
      secretKey: key,
    );
    
    return utf8.decode(clearText);
  }
}
