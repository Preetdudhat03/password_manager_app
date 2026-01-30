import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/password_model.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordModelAdapter());
  
  // Open the main box
  await Hive.openBox<PasswordModel>('passwords');

  runApp(
    const ProviderScope(
      child: PasswordManagerApp(),
    ),
  );
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
    if (state == AppLifecycleState.paused) {
      // App went to background
      // Ideally we should set a timer or just lock immediately.
      // For high security, lock immediately.
      // We clear the master key provider. This forces a re-login (biometric or password).
      // However, we must ensure we are not already on the UnlockScreen or Splash.
      // But clearing the key is safer.
      if (ref.read(masterKeyProvider) != null) {
         ref.read(masterKeyProvider.notifier).state = null;
         appRouter.go('/unlock'); 
      }
    }
    // On resume, if key is null, we should be on UnlockScreen.
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SecurePass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
