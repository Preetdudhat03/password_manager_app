import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/globals.dart';

import 'presentation/state/theme_provider.dart';

import 'presentation/state/auth_state.dart';
import 'core/services/update_service.dart';
import 'presentation/widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Init Hive
  await Hive.initFlutter();
  
  // Init Secure Storage helpers (adapters)
  await SecureStorageService().initHelpers();

  runApp(const ProviderScope(child: PasswordManagerApp()));
}

class PasswordManagerApp extends ConsumerStatefulWidget {
  const PasswordManagerApp({super.key});

  @override
  ConsumerState<PasswordManagerApp> createState() => _PasswordManagerAppState();
}

class _PasswordManagerAppState extends ConsumerState<PasswordManagerApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 1️⃣ Memory Hygiene & Auto-Lock
    // When app goes to background (paused) or is inactive (multitasking view),
    // we lock the vault immediately to prevent data exposure.
    if (state == AppLifecycleState.paused) {
      // Check if logged in first to avoid redundant calls? 
      // Logout is idempotent usually, but let's be safe.
      // We use 'read' because we are inside a callback, strictly speaking simple 'read' is fine here.
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Klypt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return UpdateCheckWrapper(child: child!);
      },
    );
  }
}

class UpdateCheckWrapper extends StatefulWidget {
  final Widget child;
  const UpdateCheckWrapper({super.key, required this.child});

  @override
  State<UpdateCheckWrapper> createState() => _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState extends State<UpdateCheckWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateService = UpdateService();
      // Auto-check respects the 24h cache rule
      final result = await updateService.checkForUpdate(isAutoCheck: true);

      if (!mounted) return;

      if (result.status == UpdateStatus.updateAvailable && result.newVersion != null) {
        showDialog(
          context: context,
          builder: (context) => UpdateDialog(versionInfo: result.newVersion!),
        );
      }
    } catch (_) {
      // Fail silently for background checks
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

