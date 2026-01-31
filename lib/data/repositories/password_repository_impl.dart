import 'package:hive/hive.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../../core/services/vault_service_locator.dart'; // Import globalVaultBox

class PasswordRepositoryImpl implements PasswordRepository {
  // We use a getter to access the global box dynamically.
  // This prevents issues where the Repository holds a reference to a CLOSED box
  // after a logout/login cycle.
  Box<VaultItem> get _box {
    if (globalVaultBox == null) {
      throw Exception('Vault is locked (Box not open)');
    }
    if (!globalVaultBox!.isOpen) {
       throw Exception('Vault is closed');
    }
    return globalVaultBox!;
  }

  // Remove constructor
  PasswordRepositoryImpl(); 

  @override
  Future<List<VaultItem>> getAllItems() async {
    return _box.values.toList();
  }

  @override
  Future<void> addItem(VaultItem item) async {
    await _box.put(item.id, item);
  }

  @override
  Future<void> updateItem(VaultItem item) async {
    await _box.put(item.id, item);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }
}
