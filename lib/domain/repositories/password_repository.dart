import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vault_item.dart';

abstract class PasswordRepository {
  Future<List<VaultItem>> getAllItems();
  Future<void> addItem(VaultItem item);
  Future<void> updateItem(VaultItem item);
  Future<void> deleteItem(String id);
}

class PasswordRepositoryImpl implements PasswordRepository {
  final Box<VaultItem> _box;

  PasswordRepositoryImpl(this._box);

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


