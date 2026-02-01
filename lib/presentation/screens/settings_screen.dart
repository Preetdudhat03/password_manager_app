import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/encryption/encryption_service.dart';
import '../../core/services/vault_service_locator.dart';
import '../../core/utils/globals.dart';
import '../state/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final BiometricService _biometricService = BiometricService();
  
  bool _biometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final key = await _storageService.getBiometricKey();
    if (mounted) {
      setState(() {
        _biometricEnabled = key != null;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    // Check hardware support first
    final canBio = await _biometricService.isBiometricAvailable;
    if (!canBio) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not supported/available')));
      return;
    }

    if (value) {
      // Enabling calls for master password confirmation
      _showEnableBiometricDialog();
    } else {
      // Disabling is easy - just delete the key slot
      // We need to add a method for this in SecureStorageService first, 
      // but for now we can overwrite it or use a specific delete method if exposed.
      // Wait, we didn't expose 'disableBiometricUnlock' in SecureStorageService.
      // We should add it.
      // Assuming we will add it:
      await _storageService.disableBiometricUnlock();
      await _checkBiometricStatus();
    }
  }

  Future<void> _showEnableBiometricDialog() async {
    final passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Biometrics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Master Password to enable biometric unlock.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              Navigator.pop(dialogContext); // Close dialog first based on async gap safety
              
              // Verify
              setState(() => _isLoading = true);
              final hiveKey = await _storageService.verifyMasterPassword(password);
              if (hiveKey != null) {
                // Save for biometrics
                await _storageService.enableBiometricUnlock(hiveKey);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics Enabled')));
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect Password')));
              }
              await _checkBiometricStatus();
              setState(() => _isLoading = false);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Master Password'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (v) => (v != null && v.length < 6) ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  validator: (v) => v != newController.text ? 'Mismatch' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final current = currentController.text;
                final newPass = newController.text;
                Navigator.pop(dialogContext);

               setState(() => _isLoading = true);
                try {
                  await _storageService.changeMasterPassword(current, newPass);
                  // Use Global Key to guarantee visibility
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('MASTER PASSWORD CHANGED SUCCESSFULLY', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    // Try to show clean error
                    String msg = e.toString();
                    if (msg.startsWith('Exception: ')) msg = msg.substring(11);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $msg')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Theme'),
        children: [
          for (var mode in ThemeMode.values)
            SimpleDialogOption(
              onPressed: () {
                ref.read(themeProvider.notifier).setTheme(mode);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(mode.toString().split('.').last.toUpperCase()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Security Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Security', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Unlock with Biometrics'),
            value: _biometricEnabled,
            onChanged: _isLoading ? null : _toggleBiometrics,
          ),
          
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change Master Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showChangePasswordDialog,
          ),

          const Divider(),

          // Appearance Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: const Text('Theme'),
            subtitle: Text(themeMode.toString().split('.').last.toUpperCase()),
            onTap: _showThemeDialog,
          ),
          
          const Divider(),

          // Data Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Data', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Backup Vault'),
            subtitle: const Text('Export encrypted backup file'),
            onTap: () => _showBackupDialog(),
          ),

          const Divider(),

          // Account Section
          const Padding(
             padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
             child: Text('Account', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Navigate to Setup screen FIRST, before auth state changes.
              // This prevents the AppRouter from forcing a redirect to /unlock
              if (mounted) context.go('/setup');

              try {
                await ref.read(authProvider.notifier).logout();
                // Invalidate repo provider to prevent stale box issues
                ref.invalidate(passwordRepositoryProvider); 
              } catch (e) {
                debugPrint('Logout error: $e');
              }
            },
          ),
          
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SecureVault v1.0.0\nOffline. Secure. Open.\n\nDeveloped by preet dudhat',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupDialog() async {
    final passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Backup Vault'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Master Password to encrypt and export your vault.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Master Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              Navigator.pop(dialogContext); // Close dialog

              setState(() => _isLoading = true);
              
              // 1. Verify Password
              try {
                // We use verifyMasterPassword just to check correctness
                final hiveKey = await _storageService.verifyMasterPassword(password);
                if (hiveKey != null) {
                  // 2. Perform Backup
                  final repo = ref.read(passwordRepositoryProvider);
                  final encryptionService = EncryptionServiceImpl();
                  
                  final backupService = BackupService(repo, encryptionService);
                  // This now calls FilePicker FIRST.
                  // If user cancels, it returns without error.
                  // How do we detect cancel? We can't easily unless we change return type of createEncryptedBackup to bool.
                  // But for now, if it returns, we assume success or cancel.
                  // If we want "Success" message ONLY on success, we should update BackupService return type.
                  // BUT, createEncryptedBackup writes file. If cancel, it returns early.
                  // We can assume if no error thrown, it's possibly success.
                  // Wait, "Backup ready to share" is wrong if they cancelled.
                  
                  // NOTE: I didn't change return type of createEncryptedBackup. 
                  // It returns Future<void>. 
                  // If user cancels, it just returns. 
                  // So we might show "Success" even if cancelled?
                  // I should probably fix BackupService to return bool or similar.
                  // But to avoid too many edits, let's just rely on "Success" message.
                  // Actually, showing "Success" when cancelled is bad.
                  
                  final success = await backupService.createEncryptedBackup(password);
                  
                  if (success) {
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('BACKUP SAVED SUCCESSFULLY', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
                    );
                  }
                } else {
                   rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('INCORRECT PASSWORD'), backgroundColor: Colors.red),
                    );
                }
              } catch (e) {
                 rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red),
                  );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

}
