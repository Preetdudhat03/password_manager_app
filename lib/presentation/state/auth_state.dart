import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vault_item.dart';
import '../../core/services/vault_service_locator.dart';
import '../../data/repositories/password_repository_impl.dart';

// State is simply "is authenticated" boolean for now
// The actual key is kept in the Hive cipher internally, we don't store it in a public provider
class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<void> login(List<int> key) async {
    // 1. Open Hive Box
    if (!Hive.isBoxOpen('vault')) {
       final box = await Hive.openBox<VaultItem>(
        'vault',
        encryptionCipher: HiveAesCipher(key),
      );
      globalVaultBox = box;
    } else {
      // Already open, verify? Assuming the key is correct if we reached here from verifyMasterPassword
      globalVaultBox = Hive.box<VaultItem>('vault');
    }
    
    // 2. Set State
    state = true;
  }

  Future<void> logout() async {
    // 1. Close Hive Box (clears decrypted data from memory)
    await globalVaultBox?.close();
    globalVaultBox = null;
    
    // 2. Clear State
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
