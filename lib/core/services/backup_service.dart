import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

    // 6. Save File using Plugin
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = 'klypt_backup_$timestamp.klypt';

    try {
      final String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: fileName,
        type: FileType.any,
        bytes: fileBytes, // Critical: Pass bytes for Android/iOS "Save As" to work
      );

      // If bytes were passed to saveFile, the plugin handles writing.
      // We just need to check if a path was returned (meaning success/not cancelled).
      if (result != null) {
        return true;
      }
    } catch (e) {
      debugPrint('Backup save error: $e');
      // Fallback: If SaveFile fails (e.g. old OS), try Share
      if (Platform.isAndroid || Platform.isIOS) {
         final tempDir = await getTemporaryDirectory();
         final file = File('${tempDir.path}/$fileName');
         await file.writeAsBytes(fileBytes);
         final result = await Share.shareXFiles([XFile(file.path)], text: 'Klypt Backup');
         return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
      }
    }

    return false;
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

    // 3. Decrypt with Fallback Strategy
    // Try current fast params first, then legacy parameters.
    final paramsToTry = [
      (mem: 4096, iter: 1),   // Current (Fast)
      (mem: 16384, iter: 2),  // Previous (Medium)
      (mem: 65536, iter: 2),  // Legacy (Strong)
    ];

    for (final p in paramsToTry) {
      debugPrint('BackupRestore: Trying params memory=${p.mem}, iter=${p.iter}...');
      try {
        final key = await _encryptionService.deriveKeyWithParams(password, salt, p.mem, p.iter);
        final jsonString = await _encryptionService.decrypt(encryptedPayload, key);
        final List<dynamic> jsonList = jsonDecode(jsonString);
        debugPrint('BackupRestore: Success with memory=${p.mem}!');
        return jsonList.map((e) => _mapToItem(e)).toList();
      } catch (e) {
        if (e.toString().contains('SecretBoxAuthenticationError')) {
           debugPrint('BackupRestore: Wrong password for params (mem=${p.mem}) - expected.');
        } else {
           debugPrint('BackupRestore: Failed with memory=${p.mem}. Error: $e');
        }
        continue;
      }
    }
    
    throw Exception('Restore failed. The password provided is incorrect.');
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
