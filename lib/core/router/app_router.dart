import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/setup_screen.dart';
import '../../presentation/screens/unlock_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/add_password_screen.dart';
import '../../domain/entities/vault_item.dart';
import '../../presentation/state/auth_state.dart';
import '../../presentation/screens/legal_document_screen.dart';
import '../../core/constants/legal_documents.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use refreshListenable to avoid rebuilding GoRouter on auth changes
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      // Use ref.read here to get current value without subscription
      final isAuth = ref.read(authProvider);
      final path = state.uri.toString();
      
      // Public routes that don't require ensuring vault is open
      if (path == '/' || path == '/setup' || path == '/unlock') {
         return null;
      }
      
      // If we are here, we are requesting a protected route
      if (!isAuth) {
        // Vault closed/locked -> Redirect to unlock
        return '/unlock';
      }
      return null;
    },
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
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Privacy Policy',
          markdownContent: LegalDocuments.privacyPolicy,
        ),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Terms & Conditions',
          markdownContent: LegalDocuments.termsAndConditions,
        ),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Security Overview',
          markdownContent: LegalDocuments.securityOverview,
        ),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
