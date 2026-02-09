import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/secure_storage_service.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1)); // Min splash time
    final storage = SecureStorageService();
    final hasPassword = await storage.hasMasterPassword();

    if (mounted) {
       if (hasPassword) {
         context.go('/unlock');
       } else {
         context.go('/setup');
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check system brightness directly since theme might not be fully ready/switched yet,
    // or use Theme.of(context).scaffoldBackgroundColor if reliable.
    // However, splash screens often default to system theme.
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Balance the text below to make the logo visually centered
            const SizedBox(height: 48), 
            const BrandLogo(width: 150),
            const SizedBox(height: 16),
             Text(
              'Klypt',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
