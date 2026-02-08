import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../../presentation/state/auth_state.dart';

class ProtectedRevealState {
  final bool isRevealed;
  final int timeRemaining;
  final bool isAuthenticating;

  const ProtectedRevealState({
    this.isRevealed = false,
    this.timeRemaining = 0,
    this.isAuthenticating = false,
  });

  ProtectedRevealState copyWith({
    bool? isRevealed,
    int? timeRemaining,
    bool? isAuthenticating,
  }) {
    return ProtectedRevealState(
      isRevealed: isRevealed ?? this.isRevealed,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }
}

class ProtectedRevealManager extends StateNotifier<ProtectedRevealState> with WidgetsBindingObserver {
  final BiometricService _biometricService;
  final SecureStorageService _storageService; // Kept for future potential usage if we need to verify directly in manager or pass keys
  Timer? _timer;
  static const int _revealDuration = 5;

  ProtectedRevealManager(this._biometricService, this._storageService) : super(const ProtectedRevealState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 4. Forced Auto-Hide Conditions
    // Password must auto-hide immediately if:
    // App goes to background, Screen turns off, or App is locked (handled by backgrounding usually)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      forceHide();
    }
  }

  void forceHide() {
    _timer?.cancel();
    if (state.isRevealed) {
      state = state.copyWith(isRevealed: false, timeRemaining: 0);
    }
  }

  /// Initiates the reveal process.
  /// 
  /// [onManualAuthRequired] is a callback that should show a UI for manual password entry (fallback).
  /// It should return true if manual auth was successful.
  Future<void> attemptReveal({required Future<bool> Function() onManualAuthRequired}) async {
    // 1. Explicit User Action & No Rapid Repeats
    if (state.isRevealed || state.isAuthenticating) return;

    state = state.copyWith(isAuthenticating: true);

    bool authenticated = false;

    try {
      // 2. Mandatory Re-Authentication

      bool canBio = await _biometricService.isBiometricAvailable;

      if (canBio) {
        // Try Biometric
        authenticated = await _biometricService.authenticate();
        // If failed/cancelled, we STOP here. We do not auto-fallback to password dialog
        // to avoid "annoying" behavior if user just cancelled.
        // If they want to use password, they must use a flow that supports it (like if the OS prompt offers it).
        // Since we can't easily distinguish 'cancel' from 'fail' in the generic boolean return, 
        // we respect the result.
      } else {
        // Only if Biometric is NOT available, we force the manual password prompt.
        authenticated = await onManualAuthRequired();
      }

      if (authenticated) {
        _startRevealTimer();
      }
    } catch (e) {
      // Edge Cases: Authentication cancelled/failed
      // Fail silently or calmly, leave masked.
      forceHide();
    } finally {
      state = state.copyWith(isAuthenticating: false);
    }
  }

  void _startRevealTimer() {
    // 3. Time-Limited Visibility
    state = state.copyWith(isRevealed: true, timeRemaining: _revealDuration);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining <= 1) {
        forceHide();
      } else {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      }
    });
  }
}

// Provider
// We use autoDispose to ensure state is cleared when the screen is closed.
final protectedRevealProvider = StateNotifierProvider.autoDispose<ProtectedRevealManager, ProtectedRevealState>((ref) {
  // Dependencies would nominally be retrieved from other providers. 
  // Since services are simple classes in this project (as seen in file views), we instantiate them.
  // Ideally we should use providers for services too if they existed.
  return ProtectedRevealManager(BiometricService(), SecureStorageService());
});
