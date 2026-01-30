import '../entities/password_entry.dart';

abstract class PasswordRepository {
  Future<List<PasswordEntry>> getAllPasswords();
  Future<void> addPassword(PasswordEntry entry);
  Future<void> updatePassword(PasswordEntry entry);
  Future<void> deletePassword(String id);
}
