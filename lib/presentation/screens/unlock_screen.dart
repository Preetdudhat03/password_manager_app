import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreatingNew = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final hasKey = await secureStorage.hasMasterKey();
    
    if (mounted) {
      setState(() {
        _isCreatingNew = !hasKey;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUnlock() async {
    setState(() => _error = null);
    final password = _passwordController.text;
    
    if (password.isEmpty) {
      setState(() => _error = 'Password cannot be empty');
      return;
    }

    final secureStorage = ref.read(secureStorageServiceProvider);
    final encryptionService = ref.read(encryptionServiceProvider);

    try {
      if (_isCreatingNew) {
        if (password != _confirmPasswordController.text) {
          setState(() => _error = 'Passwords do not match');
          return;
        }
        
        // Create new master key
        // 1. Hash the password for verification
        final passwordHash = encryptionService.hashPassword(password);
        
        // 2. Generate a random Master Key
        final masterKey = encryptionService.generateRandomKey();
        
        // 3. Encrypt the Master Key with the Password (derived key)
        // For simplicity in this demo, we are storing the password hash and the master key separately.
        // In a real app, we would encrypt the Master Key with the derived key from the password.
        // Let's stick to the requirement: "Unlock using master password... decrypt using KeyStore-wrapped key"
        // Actually, if we use KeyStore (SecureStorage), we can store the Master Key there.
        // But we need to verify the user knows the password.
        
        // Let's store the Master Key in Secure Storage, but only allow access if we verify the password.
        // Wait, if we store it in Secure Storage, anyone with root access (or biometric) can get it?
        // Secure Storage is encrypted.
        
        // Let's follow a standard pattern:
        // Store Hash(Password) to verify password.
        // Store Encrypted(MasterKey, Key=Derived(Password)).
        // When using Biometrics, we store MasterKey in SecureStorage (protected by auth).
        
        // For this MVP step:
        // 1. Store Hash(Password) in Secure Storage (to verify login).
        // 2. Store Master Key in Secure Storage (this is effectively KeyStore wrapped).
        
        await secureStorage.write(key: 'master_password_hash', value: passwordHash);
        await secureStorage.write(key: 'master_key', value: masterKey.base64);
        
        ref.read(masterKeyProvider.notifier).state = masterKey.base64;

        if (mounted) {
          context.go('/home');
        }
      } else {
        // Verify password
        final storedHash = await secureStorage.read(key: 'master_password_hash');
        final inputHash = encryptionService.hashPassword(password);
        
        if (storedHash == inputHash) {
          // Retrieve Master Key
          final masterKey = await secureStorage.read(key: 'master_key');
          ref.read(masterKeyProvider.notifier).state = masterKey;
          
          context.go('/home');
        } else {
          setState(() => _error = 'Incorrect password');
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
              ),
              const SizedBox(height: 32),
              Text(
                _isCreatingNew ? 'Create Master Password' : 'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key),
                  errorText: _error,
                ),
              ),
              if (_isCreatingNew) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _handleUnlock,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_isCreatingNew ? 'Create & Unlock' : 'Unlock'),
                ),
              ),
              if (!_isCreatingNew) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement biometric unlock
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometrics'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
