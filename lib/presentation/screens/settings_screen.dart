import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_service.dart';
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
      builder: (context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              Navigator.pop(context); // Close dialog first based on async gap safety
              
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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final current = currentController.text;
                final newPass = newController.text;
                Navigator.pop(context);

               setState(() => _isLoading = true);
                try {
                  await _storageService.changeMasterPassword(current, newPass);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
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
          
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SecureVault v1.0.0\nOffline. Secure. Open.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

