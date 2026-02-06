import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/vault_service_locator.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/password_repository.dart';
import '../state/auth_state.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  final SecureStorageService _storageService = SecureStorageService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Don't auto-prompt/show errors on load, just check silent availability
    _checkAutoBiometric();
  }

  Future<void> _checkAutoBiometric() async {
    final canBio = await _biometricService.isBiometricAvailable;
    if (!canBio) return;
    
    final storedKey = await _storageService.getBiometricKey();
    if (storedKey != null) {
      _tryBiometric(); // Only try if we KNOW we have a key
    }
  }

  Future<void> _tryBiometric() async {
    // Check if biometric is available and enabled
    final canBio = await _biometricService.isBiometricAvailable;
    if (!canBio) {
      if (mounted) setState(() => _error = "Biometrics not supported/available");
      return;
    }

    // Check if we have a stored biometric key
    final storedKey = await _storageService.getBiometricKey();
    if (storedKey == null) {
      if (mounted && _error != null) return; // Silent if error already shown or auto-run
      // Only show this message if the function was triggered by a user action (e.g. button press).
      // We can check if _isLoading is false (usually) or pass a flag.
      // But for simplicity, we'll just check if the widget is fully rendered/interactive.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unlock with password first to enable biometrics.")),
        );
      }
      return;
    }

    // Prompt user
    try {
      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        setState(() => _isLoading = true);
        await ref.read(authProvider.notifier).login(storedKey);
        
        // Memory Hygiene: Clear controllers if any
        _passwordController.clear();
        
        if (mounted) context.go('/home');
      } else {
        setState(() => _error = "Biometric authentication failed");
      }
    } catch (e) {
      setState(() => _error = "Biometric error: $e");
    }
  }

  Future<void> _unlock() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final password = _passwordController.text;

    try {
      final hiveKey = await _storageService.verifyMasterPassword(password);
      
      if (mounted) {
        // Initialize Hive Box with this key via AuthNotifier
        await ref.read(authProvider.notifier).login(hiveKey);
        
        // Memory Hygiene
        _passwordController.clear();
        
        // Auto-enable biometrics if available and not set
        final canBio = await _biometricService.isBiometricAvailable;
        if (canBio) {
          await _storageService.enableBiometricUnlock(hiveKey);
        }

        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Clean up the exception message for UI
          String msg = e.toString();
          if (msg.startsWith("Exception: ")) {
            msg = msg.substring(11);
          }
          _error = msg;
          _isLoading = false;
        });
      }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    LucideIcons.unlock,
                    size: 64,
                    color: Color(0xFFD0BCFF),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Unlock Vault',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      prefixIcon: const Icon(LucideIcons.key),
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _unlock,
                    child: _isLoading 
                        ? const CircularProgressIndicator()
                        : const Text('Unlock'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _tryBiometric, child: const Text('Use Biometrics')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
