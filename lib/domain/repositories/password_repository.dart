import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vault_item.dart';

abstract class PasswordRepository {
  Future<List<VaultItem>> getAllItems();
  Future<void> addItem(VaultItem item);
  Future<void> updateItem(VaultItem item);
  Future<void> deleteItem(String id);
}




