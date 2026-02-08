import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/security/protected_reveal_manager.dart';
import '../../core/services/secure_storage_service.dart';

/// A secure toggle for password visibility that requires authentication.
/// Handles the UI for the "Protected Reveal" feature.
class PasswordVisibilityToggle extends ConsumerWidget {
  /// Callback when visibility state changes.
  /// True = Visible (Revealed), False = Hidden (Obscured).
  final ValueChanged<bool> onVisibilityChanged;

  const PasswordVisibilityToggle({
    super.key,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revealState = ref.watch(protectedRevealProvider);
    final isRevealed = revealState.isRevealed;
    final timeRemaining = revealState.timeRemaining;
    final isAuthenticating = revealState.isAuthenticating;

    // Listen to state changes to notify parent
    ref.listen<ProtectedRevealState>(protectedRevealProvider, (previous, next) {
      if (previous?.isRevealed != next.isRevealed) {
        onVisibilityChanged(next.isRevealed);
      }
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Countdown Indicator
        if (isRevealed)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                "Visible for ${timeRemaining}s",
                key: ValueKey(timeRemaining),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
          ),
        
        // Toggle Button
        IconButton(
          onPressed: isAuthenticating 
              ? null 
              : () {
                  if (isRevealed) {
                    ref.read(protectedRevealProvider.notifier).forceHide();
                  } else {
                    ref.read(protectedRevealProvider.notifier).attemptReveal(
                      onManualAuthRequired: () => _showManualAuthDialog(context),
                    );
                  }
                },
          icon: isAuthenticating 
              ? SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Icon(
                  isRevealed ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: isRevealed 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          tooltip: isRevealed ? "Hide Password" : "Show Password",
        ),
      ],
    );
  }

  Future<bool> _showManualAuthDialog(BuildContext context) async {
    final controller = TextEditingController();
    final secureStorage = SecureStorageService();
    String? errorText;

    // We use a StatefulBuilder to update error text inside dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow cancel
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Verify Identity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter your master password to reveal.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      errorText: errorText,
                      prefixIcon: const Icon(LucideIcons.key),
                    ),
                    onSubmitted: (_) async {
                      // Trigger verify logic
                      // We can't easily trigger the button's onPressed here without duplication or structure
                      // But we can replicate logic:
                      try {
                        setState(() => errorText = null);
                        await secureStorage.verifyMasterPassword(controller.text);
                        if (context.mounted) Navigator.of(context).pop(true);
                      } catch (e) {
                         if (context.mounted) setState(() => errorText = "Incorrect password");
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      setState(() => errorText = null);
                      await secureStorage.verifyMasterPassword(controller.text);
                      if (context.mounted) Navigator.of(context).pop(true);
                    } catch (e) {
                      if (context.mounted) setState(() => errorText = "Incorrect password"); 
                    }
                  },
                  child: const Text('Reveal'),
                ),
              ],
            );
          }
        );
      },
    );

    controller.dispose();
    return result ?? false;
  }
}
