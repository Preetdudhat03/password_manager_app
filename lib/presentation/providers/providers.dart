import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/encryption/encryption_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_service.dart';
import '../../data/models/password_model.dart';
import '../../data/repositories/password_repository_impl.dart';
import '../../domain/repositories/password_repository.dart';
import '../../domain/entities/password_entry.dart';

// Services
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

// Hive Box
final passwordBoxProvider = Provider<Box<PasswordModel>>((ref) {
  return Hive.box<PasswordModel>('passwords');
});

// Repository
final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  final box = ref.watch(passwordBoxProvider);
  return PasswordRepositoryImpl(box);
});

// App State
final masterKeyProvider = StateProvider<String?>((ref) => null);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchVisibleProvider = StateProvider<bool>((ref) => false);

final passwordsProvider = FutureProvider<List<PasswordEntry>>((ref) async {
  final repository = ref.read(passwordRepositoryProvider);
  return repository.getAllPasswords();
});

final filteredPasswordsProvider = Provider<AsyncValue<List<PasswordEntry>>>((ref) {
  final passwordsAsync = ref.watch(passwordsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return passwordsAsync.whenData((passwords) {
    if (query.isEmpty) return passwords;
    return passwords.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
             entry.username.toLowerCase().contains(query);
    }).toList();
  });
});
