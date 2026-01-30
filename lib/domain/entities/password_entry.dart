class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String encryptedPassword;
  final DateTime? lastModified;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.lastModified,
  });
}
