import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';

// Global variable to hold the box once opened
Box<VaultItem>? globalVaultBox;

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  if (globalVaultBox == null) {
    // This might happen if the provider is read before the vault is unlocked.
    // In a real app, we would use a FutureProvider or similar.
    // However, since we block navigation at the Splash/Unlock screen until the vault is ready,
    // this check is primarily a fail-safe.
    throw Exception('Vault not opened yet');
  }
  return PasswordRepositoryImpl(globalVaultBox!);
});
