import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/security/clipboard_manager.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/secure_storage_service.dart';

/// SmartCopyActions Widget
/// 
/// Displays context-aware copy buttons for Username and Password.
/// Handles authentication for password copying and provides live feedback.
class SmartCopyActions extends ConsumerWidget {
  final String username;
  final String password;

  const SmartCopyActions({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clipboardState = ref.watch(clipboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Feedback Area (Countdown)
        if (clipboardState.isCopied)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.timer, 
                  size: 16, 
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${clipboardState.type} copied — clears in ${clipboardState.remainingSeconds}s',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(clipboardProvider.notifier).clearClipboard();
                  },
                  child: const Text('Speed Clear'),
                ),
              ],
            ),
          ),

        // 2. Action Buttons
        Row(
          children: [
            // Username - Low Friction
            Expanded(
              child: _CopyButton(
                icon: LucideIcons.user,
                label: 'Copy User',
                isCreateSensitive: false,
                onTap: () {
                  ref.read(clipboardProvider.notifier).copySecurely(username, 'Username');
                },
              ),
            ),
            const SizedBox(width: 8),
            // Password - High Security
            Expanded(
              child: _CopyButton(
                icon: LucideIcons.key,
                label: 'Copy Pass',
                isCreateSensitive: true,
                onTap: () async {
                  await _handlePasswordCopy(context, ref);
                },
              ),
            ),
          ],
        ),
        if (kIsWeb)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.alertTriangle, size: 14, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Browser limit: Clipboard history cannot be managed. Run on Desktop for full security.',
                    style: TextStyle(fontSize: 11, color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _handlePasswordCopy(BuildContext context, WidgetRef ref) async {
    // 1. Auth Check Logic
    // In a real scenario, we should prompt Biometric.
    // If not enabled, fallback to Master Password (or just allow if unlocked app state is trusted).
    // The requirement says: "Require biometric authentication OR master password".
    // Since the user is IN the app, they 'unlocked' it. But 're-authentication' is requested.
    
    final bioService = BiometricService();
    final canBio = await bioService.isBiometricAvailable;
    
    bool authenticated = false;

    if (canBio) {
      authenticated = await bioService.authenticate();
    } else {
      // Fallback: Prompt Master Password if biometrics unavailable
      // For simplicity in this iteration, if no bio hardware, we might skip or prompt text.
      // Let's implement a simple dialog fallback.
      if (context.mounted) {
        authenticated = await _showPasswordPrompt(context);
      }
    }

    if (authenticated) {
      ref.read(clipboardProvider.notifier).copySecurely(password, 'Password');
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _showPasswordPrompt(BuildContext context) async {
    final controller = TextEditingController();
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        
        // Define submit logic here to share between button and Enter key
        Future<void> submit(StateSetter setState) async {
             setState(() => isLoading = true);
             // Give UI a moment to draw the spinner
             await Future.delayed(const Duration(milliseconds: 50));
             
             final storage = SecureStorageService();
             try {
               await storage.verifyMasterPassword(controller.text);
               if (context.mounted) {
                 Navigator.pop(context, true);
               }
             } catch (e) {
               if (context.mounted) {
                 // Reset loading to let them try again or show error
                 setState(() => isLoading = false);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password'), backgroundColor: Colors.red),
                 );
               }
             }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Verify Identity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: const InputDecoration(labelText: 'Master Password'),
                    onSubmitted: (_) => isLoading ? null : submit(setState),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: isLoading ? null : () => submit(setState),
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    ) ?? false;
  }
}

class _CopyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCreateSensitive;
  final VoidCallback onTap;

  const _CopyButton({
    required this.icon,
    required this.label,
    required this.isCreateSensitive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Style differentiation
    final baseColor = isCreateSensitive 
        ? Colors.amber.shade700 // Caution
        : Theme.of(context).colorScheme.primary; // Friendly
    
    final bgColor = isCreateSensitive
        ? Colors.amber.withOpacity(0.1)
        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: baseColor, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: baseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
