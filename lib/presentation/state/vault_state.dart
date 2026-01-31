import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../../core/services/vault_service_locator.dart';

import '../state/auth_state.dart';

final vaultListProvider = StateNotifierProvider<VaultListNotifier, List<VaultItem>>((ref) {
  // Watch auth state so we rebuild (and reload items) when user logs in/out.
  ref.watch(authProvider);
  
  final repository = ref.watch(passwordRepositoryProvider);
  return VaultListNotifier(repository);
});

class VaultListNotifier extends StateNotifier<List<VaultItem>> {
  final PasswordRepository _repository;

  VaultListNotifier(this._repository) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _repository.getAllItems();
      // Sort by updated descending
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = items;
    } catch (e) {
      // If repository fails (e.g. vault locked during logout), we set empty state
      // to avoid 'Vault not opened yet' crashes.
      state = [];
    }
  }

  Future<void> add(VaultItem item) async {
    await _repository.addItem(item);
    await _loadItems();
  }

  Future<void> update(VaultItem item) async {
    await _repository.updateItem(item);
    await _loadItems();
  }

  Future<void> delete(String id) async {
    await _repository.deleteItem(id);
    await _loadItems();
  }
}
