import 'package:dabbler/core/config/environment.dart';
import 'package:dabbler/themes/app_theme.dart';
import 'package:dabbler/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants/route_constants.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await Environment.load();

  // Initialize theme service
  await ThemeService().init();

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  // Listen to auth state changes and persist state if needed
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      // The user clicked the reset link; show reset UI
      // Defer to router after the first frame to ensure context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go(RoutePaths.resetPassword);
      });
    }
    // TODO: Dispatch to Riverpod/global state, persist tokens, etc.
  });

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Dabbler',
          routerConfig: appRouter,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.effectiveThemeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}