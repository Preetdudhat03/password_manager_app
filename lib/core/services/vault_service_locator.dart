import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../../data/repositories/password_repository_impl.dart';

// Global variable to hold the box once opened
Box<VaultItem>? globalVaultBox;

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  // We return the implementation directly. 
  // The implementation checks for the opened box internally when methods are called.
  // This prevents crashes when the provider is rebuilt during logout (when box is null).
  return PasswordRepositoryImpl();
});
