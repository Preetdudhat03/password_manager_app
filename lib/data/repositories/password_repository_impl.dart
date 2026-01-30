import 'package:hive/hive.dart';
import '../../domain/entities/password_entry.dart';
import '../../domain/repositories/password_repository.dart';
import '../models/password_model.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  final Box<PasswordModel> _box;

  PasswordRepositoryImpl(this._box);

  @override
  Future<List<PasswordEntry>> getAllPasswords() async {
    return _box.values.toList();
  }

  @override
  Future<void> addPassword(PasswordEntry entry) async {
    final model = PasswordModel.fromEntity(entry);
    await _box.put(entry.id, model);
  }

  @override
  Future<void> updatePassword(PasswordEntry entry) async {
    final model = PasswordModel.fromEntity(entry);
    await _box.put(entry.id, model);
  }

  @override
  Future<void> deletePassword(String id) async {
    await _box.delete(id);
  }
}
