import 'package:hive/hive.dart';
import '../../domain/entities/password_entry.dart';

@HiveType(typeId: 0)
class PasswordModel extends PasswordEntry {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String encryptedPassword;
  @HiveField(4)
  final DateTime? lastModified;

  PasswordModel({
    required this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.lastModified,
  }) : super(
          id: id,
          title: title,
          username: username,
          encryptedPassword: encryptedPassword,
          lastModified: lastModified,
        );

  factory PasswordModel.fromEntity(PasswordEntry entry) {
    return PasswordModel(
      id: entry.id,
      title: entry.title,
      username: entry.username,
      encryptedPassword: entry.encryptedPassword,
      lastModified: entry.lastModified,
    );
  }
}

class PasswordModelAdapter extends TypeAdapter<PasswordModel> {
  @override
  final int typeId = 0;

  @override
  PasswordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordModel(
      id: fields[0] as String,
      title: fields[1] as String,
      username: fields[2] as String,
      encryptedPassword: fields[3] as String,
      lastModified: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.encryptedPassword)
      ..writeByte(4)
      ..write(obj.lastModified);
  }
}
