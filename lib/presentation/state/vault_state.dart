import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../../core/services/vault_service_locator.dart';
import '../../domain/usecases/filter_vault_items.dart';

import '../state/auth_state.dart';

final vaultListProvider = StateNotifierProvider<VaultListNotifier, List<VaultItem>>((ref) {
  // Watch auth state so we rebuild (and reload items) when user logs in/out.
  ref.watch(authProvider);
  
  final repository = ref.watch(passwordRepositoryProvider);
  return VaultListNotifier(repository);
});

enum SortType {
  dateNewest,
  dateOldest,
  alphaAZ,
  alphaZA,
}

final sortProvider = StateProvider<SortType>((ref) => SortType.dateNewest);

final sortedVaultListProvider = Provider<List<VaultItem>>((ref) {
  final items = ref.watch(vaultListProvider);
  final sortType = ref.watch(sortProvider);

  // We create a new list to avoid mutating the state directly if it was mutable (though usually fine here)
  final sortedItems = List<VaultItem>.from(items);

  switch (sortType) {
    case SortType.dateNewest:
      sortedItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case SortType.dateOldest:
      sortedItems.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      break;
    case SortType.alphaAZ:
      sortedItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case SortType.alphaZA:
      sortedItems.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      break;
  }
  return sortedItems;
});

// SEARCH STATE MANAGEMENT
final vaultSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredVaultListProvider = Provider<List<VaultItem>>((ref) {
  final query = ref.watch(vaultSearchQueryProvider);
  final items = ref.watch(sortedVaultListProvider);

  if (query.isEmpty) return items;

  // Use the usecase for clean separation
  return FilterVaultItems()(items, query);
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
