import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/encryption/encryption_service.dart';
import '../../core/services/backup_service.dart';
import '../../data/repositories/password_repository_impl.dart';
import '../../domain/entities/vault_item.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _createMasterPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Ensure we start fresh
      await Hive.deleteBoxFromDisk('vault');

      final storage = SecureStorageService(); // Should be provded by DI in real app
      await storage.setMasterPassword(_passwordController.text);
      
      setState(() => _isLoading = false);
      if (mounted) context.go('/unlock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      size: 64,
                      color: Color(0xFFD0BCFF),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Create Master Password',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                     Text(
                      'This password encrypts your entire vault. It cannot be recovered if lost.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Master Password',
                        prefixIcon: Icon(LucideIcons.key),
                      ),
                      validator: (value) {
                        if (value == null) return 'Required';
                        if (value.trim().length < 6) return 'Min 6 characters (trimmed)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(LucideIcons.check),
                      ),
                      validator: (value) => 
                        value != _passwordController.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createMasterPassword,
                      child: _isLoading 
                        ? const CircularProgressIndicator()
                        : const Text('Create Vault'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _restoreFromBackup,
                      child: const Text('Restore from Backup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restoreFromBackup() async {
    // 1. Pick File with bytes loaded
    final result = await FilePicker.platform.pickFiles(
      withData: true, // IMPORTANT for Web/Windows sometimes
    );
    if (result == null) return;
    
    // On some platforms (web), path might be null or inaccessible.
    // Use bytes directly if available.
    final Uint8List fileBytes = result.files.single.bytes ?? await File(result.files.single.path!).readAsBytes();
    
    // 2. Ask for Backup Password
    final backupPass = await _promptPassword(context, 'Enter Backup Password');
    if (backupPass == null) return;

    setState(() => _isLoading = true);

    try {
      // 3. Decrypt
      // We need services. In real app, use DI.
      final crypto = EncryptionServiceImpl();
      final backup = BackupService(PasswordRepositoryImpl(), crypto);
      
      // Pass bytes directly to restoreBackup
      final items = await backup.restoreBackupFromBytes(fileBytes, backupPass);
      
      // 4. Ask for New Master Password (to encrypt the vault on this device)
      if (mounted) {
        setState(() => _isLoading = false); // pause loading to show dialog
        final newMasterPass = await _promptPassword(context, 'Set New Master Password');
        if (newMasterPass == null) return; // Abort
        
        setState(() => _isLoading = true); // resume

        // 5. Initialize Vault
        // Clean up old data to avoid key mismatch
        await Hive.deleteBoxFromDisk('vault');
        
        final storage = SecureStorageService();
        await storage.setMasterPassword(newMasterPass);
        
        // 6. Login (Open Box)
        // We need to verify to get the key and open box.
        // We can reuse AuthNotifier logic or manually do it.
        // Let's use AuthNotifier if possible, or manual.
        // Manual: Verify -> Get Key -> Open Box -> Set Global -> Add Items.
        
        final hiveKey = await storage.verifyMasterPassword(newMasterPass);
        // We must Open Box manually here to seed it.
        // But usually AuthNotifier handles this.
        // Let's call AuthNotifier.login
        // We need `ref` access. SetupScreen is StatefulWidget, NOT ConsumerStatefulWidget.
        // We should convert it to Consumer.
        // OR just rely on manual box open for seeding.
        
        final key = hiveKey;
        if (key != null) {
          // Open box temporarily to seed
           final box = await Hive.openBox<VaultItem>(
            'vault',
            encryptionCipher: HiveAesCipher(key),
          );
          
          for (var item in items) {
            await box.put(item.id, item);
          }
           await box.close(); // Close so AuthNotifier can open it freshly
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restored successfully! Please login.')));
             context.go('/unlock');
           }
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _promptPassword(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('OK')),
        ],
      ),
    );
  }
}
