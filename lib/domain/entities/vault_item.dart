import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'vault_item.g.dart';

@HiveType(typeId: 0)
class VaultItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  const VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  VaultItem copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, username, password, notes, createdAt, updatedAt];
}

