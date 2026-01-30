import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Preferences'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeModeProvider.notifier).state = newMode;
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Unlock'),
            subtitle: const Text('Use fingerprint to unlock'),
            trailing: Switch(
              value: true, // TODO: Implement reading from storage
              onChanged: (value) {
                // TODO: Implement toggle
              },
            ),
            onTap: () {
               // Verify biometrics first
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Change Master Password'),
            onTap: () {
              // Navigate to change password screen (not implemented yet)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data',
                style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your passwords and reset the app. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 1. Clear Hive Box
      final box = ref.read(passwordBoxProvider);
      await box.clear();

      // 2. Clear Secure Storage
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.deleteAll();

      // 3. Reset State
      ref.read(masterKeyProvider.notifier).state = null;
      ref.invalidate(passwordsProvider);

      // 4. Navigate to Splash (restart/re-onboard)
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}
