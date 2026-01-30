import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/unlock_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/add_password_screen.dart';
import '../../presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
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
      path: '/add-password',
      builder: (context, state) => const AddPasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  redirect: (context, state) {
     // TODO: Implement proper auth guard reading from ProviderContainer if available
     // But GoRouter doesn't have ref access easily here without passing it.
     // For now, rely on manual navigation.
     return null;
  },
);
