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
  
  // Biometrics
  bool _canCheckBiometrics = false;
  bool _useBiometrics = false; // For setup checkbox

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final biometricService = ref.read(biometricServiceProvider);
    
    final hasKey = await secureStorage.hasMasterKey();
    final canCheck = await biometricService.isBiometricAvailable();
    
    // Check if biometrics was previously enabled
    final biometricsEnabledStr = await secureStorage.read(key: 'biometrics_enabled');
    final biometricsEnabled = biometricsEnabledStr == 'true';

    if (mounted) {
      setState(() {
        _isCreatingNew = !hasKey;
        _canCheckBiometrics = canCheck;
        _isLoading = false;
        // If not creating new, we might auto-trigger biometric if enabled
        if (!hasKey) {
             _useBiometrics = canCheck; // Default to true if available during setup
        }
      });
      
      if (hasKey && biometricsEnabled && canCheck) {
        // Optional: Auto-trigger biometric prompt
        // _handleBiometricUnlock(); 
      }
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
        final passwordHash = encryptionService.hashPassword(password);
        final masterKey = encryptionService.generateRandomKey();
        
        // Save Everything
        await secureStorage.write(key: 'master_password_hash', value: passwordHash);
        await secureStorage.write(key: 'master_key', value: masterKey.base64);
        
        // Save Biometric Preference
        if (_canCheckBiometrics) {
           await secureStorage.write(key: 'biometrics_enabled', value: _useBiometrics.toString());
        }
        
        ref.read(masterKeyProvider.notifier).state = masterKey.base64;

        if (mounted) {
          context.go('/home');
        }
      } else {
        // Verify password
        final storedHash = await secureStorage.read(key: 'master_password_hash');
        final inputHash = encryptionService.hashPassword(password);
        
        if (storedHash == inputHash) {
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
  
  Future<void> _handleBiometricUnlock() async {
    final biometricService = ref.read(biometricServiceProvider);
    final secureStorage = ref.read(secureStorageServiceProvider);
    
    final authenticated = await biometricService.authenticate();
    if (authenticated) {
      try {
        final masterKey = await secureStorage.read(key: 'master_key');
        if (masterKey != null) {
           ref.read(masterKeyProvider.notifier).state = masterKey;
           if (mounted) context.go('/home');
        } else {
           setState(() => _error = 'Master Key not found. Please reset app.');
        }
      } catch (e) {
         setState(() => _error = 'Error retrieving key: $e');
      }
    } else {
      // Failed authentication (canceled or error)
      // Usually UI feedback handles itself, but we can set error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                  if (_canCheckBiometrics) ...[
                     const SizedBox(height: 16),
                     SwitchListTile(
                       title: const Text('Enable Biometric Unlock'),
                       value: _useBiometrics,
                       onChanged: (val) => setState(() => _useBiometrics = val),
                     ),
                  ]
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _handleUnlock,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_isCreatingNew ? 'Create & Unlock' : 'Unlock'),
                  ),
                ),
                if (!_isCreatingNew && _canCheckBiometrics) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _handleBiometricUnlock,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometrics'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
