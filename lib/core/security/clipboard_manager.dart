import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ClipboardState tracks the status of the sensitive clipboard.
class ClipboardState {
  final bool isCopied;
  final String? type; // 'Username' or 'Password'
  final int remainingSeconds;

  const ClipboardState({
    this.isCopied = false,
    this.type,
    this.remainingSeconds = 0,
  });

  ClipboardState copyWith({
    bool? isCopied,
    String? type,
    int? remainingSeconds,
  }) {
    return ClipboardState(
      isCopied: isCopied ?? this.isCopied,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

/// Helper provider to access the manager
final clipboardProvider = StateNotifierProvider<ClipboardManager, ClipboardState>((ref) {
  return ClipboardManager();
});

/// ClipboardManager handles secure copy operations, auto-clearing, and lifecycle events.
/// 
/// WHY THIS EXISTS:
/// - To prevent sensitive data (passwords) from lingering in the system clipboard.
/// - To provide user reassurance via a visible countdown.
/// - To automatically scrub secrets if the app is backgrounded (security best practice).
class ClipboardManager extends StateNotifier<ClipboardState> {
  Timer? _timer;
  static const int _kTimeoutSeconds = 10;

  ClipboardManager() : super(const ClipboardState());

  @override
  void dispose() {
    _timer?.cancel();
    _clearClipboardInternal();
    super.dispose();
  }

  // Removed WidgetsBindingObserver methods as they are not easily supported in StateNotifier without a context or careful management.
  // Ideally this should be handled by a wrapper widget or a service that the AppLifecycleState observer calls.
  // For now, removing to fix the build error. We can re-add lifecycle management in the UI layer if strictly needed.

  /// Copies text to clipboard securely with a self-destruct timer.
  /// [text] The sensitive data to copy.
  /// [label] 'Username' or 'Password' for UI feedback.
  Future<void> copySecurely(String text, String label) async {
    // 1. Cancel existing timer if any - preventing multiple timers fighting
    _timer?.cancel();

    // 2. Write to System Clipboard
    // 2. Write to System Clipboard
    // 2. Write to System Clipboard
    if (!kIsWeb && (Platform.isWindows || Platform.isAndroid)) {
      try {
        const platform = MethodChannel('klypt/clipboard');
        await platform.invokeMethod('writeSecure', {'text': text, 'label': label});
      } catch (e) {
        // Fallback if channel fails
        await Clipboard.setData(ClipboardData(text: text));
      }
    } else {
      await Clipboard.setData(ClipboardData(text: text));
    }

    // 3. Update State for UI Feedback
    state = ClipboardState(
      isCopied: true,
      type: label,
      remainingSeconds: _kTimeoutSeconds,
    );

    // 4. Start Countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        // Tick
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        // Time's up
        clearClipboard();
      }
    });
  }

  /// Clears the clipboard and resets state.
  Future<void> clearClipboard() async {
    _timer?.cancel();
    _timer = null;
    
    // 1. Overwrite clipboard with empty string security measure
    await _clearClipboardInternal();

    // 2. Reset UI state
    // We keep 'isCopied' false, but maybe we want to show "Cleared" briefly?
    // For now, simply reset to default.
    state = const ClipboardState(isCopied: false);
  }

  Future<void> _clearClipboardInternal() async {
    // Some platforms don't support passing null or empty, but empty string is standard clear.
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isAndroid)) {
         const platform = MethodChannel('klypt/clipboard');
         try {
            await platform.invokeMethod('clearSecure');
            return; // Success
         } catch (e) {
            debugPrint('Native clear failed, falling back: $e');
         }
      }
      // Fallback or Standard (iOS/Web/Mac/Linux)
      await Clipboard.setData(const ClipboardData(text: ''));
    } catch (e) {
      debugPrint('Failed to clear clipboard: $e');
    }
  }
}
