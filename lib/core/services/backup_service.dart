import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../encryption/encryption_service.dart';

class BackupService {
  final PasswordRepository _repository;
  final EncryptionService _encryptionService;

  BackupService(this._repository, this._encryptionService);

  Future<bool> createEncryptedBackup(String masterPassword) async {
    // 1. Generate Salt for Backup (Moved back to top)
    final salt = Uint8List.fromList(List<int>.generate(16, (i) => DateTime.now().microsecondsSinceEpoch % 255));

    // 2. Get All Data
    final items = await _repository.getAllItems();
    final jsonList = items.map((e) => _itemToMap(e)).toList();
    final jsonString = jsonEncode(jsonList);

    // 3. Derive Key
    final key = await _encryptionService.deriveKey(masterPassword, salt);

    // 4. Encrypt Data
    final encryptedBytes = await _encryptionService.encrypt(jsonString, key);

    // 5. Combine Salt + Data
    final fileBytes = Uint8List.fromList([...salt, ...encryptedBytes]);

    // 6. Save File using Plugin (Pass bytes for Android/iOS support)
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = 'klypt_backup_$timestamp.klypt';

    final String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup File',
      fileName: fileName,
      type: FileType.any,
      bytes: fileBytes, // Pass bytes directly
    );

    return result != null;
  }

  Map<String, dynamic> _itemToMap(VaultItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'username': item.username,
      'password': item.password,
      'notes': item.notes,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  Future<List<VaultItem>> restoreBackup(File file, String password) async {
    final bytes = await file.readAsBytes();
    return restoreBackupFromBytes(bytes, password);
  }

  Future<List<VaultItem>> restoreBackupFromBytes(Uint8List bytes, String password) async {
    if (bytes.length < 16) throw Exception('Invalid backup file');

    // 1. Extract Salt
    final salt = bytes.sublist(0, 16);
    final encryptedPayload = bytes.sublist(16);

    // 2. Derive Key
    final key = await _encryptionService.deriveKey(password, salt);

    // 3. Decrypt
    try {
      final jsonString = await _encryptionService.decrypt(encryptedPayload, key);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      return jsonList.map((e) => _mapToItem(e)).toList();
    } catch (e) {
      throw Exception('Decryption failed. Wrong password?');
    }
  }

  VaultItem _mapToItem(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
