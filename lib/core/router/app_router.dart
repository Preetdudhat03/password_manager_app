import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/setup_screen.dart';
import '../../presentation/screens/unlock_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/add_password_screen.dart';
import '../../domain/entities/vault_item.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/unlock',
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/add_password',
        builder: (context, state) => const AddPasswordScreen(),
      ),
      GoRoute(
        path: '/edit_password',
        builder: (context, state) {
          final item = state.extra as VaultItem;
          return AddPasswordScreen(itemToEdit: item);
        },
      ),
    ],
  );
});
