import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../screens/home/home_screen.dart';
import '../features/error/presentation/pages/error_page.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/register_screen.dart';
import '../features/authentication/presentation/screens/enter_password_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/authentication/presentation/screens/reset_password_screen.dart';
import '../screens/onboarding/create_user_information.dart';
import '../screens/onboarding/sports_selection_screen.dart';
import '../screens/onboarding/intent_selection_screen.dart';
import '../screens/onboarding/set_password_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../utils/constants/route_constants.dart';
import '../features/authentication/presentation/providers/auth_providers.dart';
import '../screens/design_system_demo.dart';
// Game feature imports - TODO: Uncomment when screens are implemented
// import '../features/games/presentation/screens/games_home_screen.dart';
// import '../features/games/presentation/screens/available_games_screen.dart';
// import '../features/games/presentation/screens/game_detail_screen.dart';
// import '../features/games/presentation/screens/venues_list_screen.dart';
// import '../features/games/presentation/screens/venue_detail_screen.dart';
// import '../features/games/presentation/screens/create_game_basic_info_screen.dart';
// import '../features/games/presentation/screens/create_game_venue_selection_screen.dart';
// import '../features/games/presentation/screens/create_game_date_time_screen.dart';
// import '../features/games/presentation/screens/create_game_player_settings_screen.dart';
// import '../features/games/presentation/screens/create_game_pricing_screen.dart';
// import '../features/games/presentation/screens/create_game_additional_details_screen.dart';
// import '../features/games/presentation/screens/create_game_review_screen.dart';
// import '../features/games/presentation/screens/game_checkin_screen.dart';
// import '../features/games/presentation/screens/game_lobby_screen.dart';
// import '../features/games/presentation/screens/live_game_screen.dart';
// import '../features/games/presentation/screens/post_game_screen.dart';
// import '../features/games/presentation/screens/my_games_screen.dart';
// import '../features/games/presentation/screens/game_history_screen.dart';
import '../features/games/presentation/screens/create_game/create_game_screen.dart';


// Export GoRouter instance for use in main.dart
final appRouter = AppRouter.router;

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Analytics Observer
  static final _routeObserver = RouteObserver<ModalRoute<void>>();
  static RouteObserver<ModalRoute<void>> get routeObserver => _routeObserver;

  // Router Instance
  // Toggle for verbose route logging (only active in debug mode)
  static const bool _routeLogging = true; // set false to silence even debug prints

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false, // reduce noisy full route dumps in console
    observers: [_routeObserver],
    errorBuilder: (context, state) => ErrorPage(
      message: state.error?.message,
    ),
  redirect: _handleRedirect,
    routes: _routes,
  );

  // Auth Redirect Logic
  static FutureOr<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    if (kDebugMode && _routeLogging) {
      // Compact single-line log
      debugPrint('🔍 route check -> ${state.matchedLocation}');
    }

    // Access Riverpod container to read auth/guest state
    final container = ProviderScope.containerOf(context, listen: false);
    final isAuthenticated = container.read(isAuthenticatedProvider);
    final isGuest = container.read(isGuestProvider);

    if (kDebugMode && _routeLogging) {
      debugPrint('🔍 auth: auth=$isAuthenticated guest=$isGuest');
    }

    // Centralised set for auth/onboarding related routes
    const authPaths = <String>{
      // core auth
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.enterPassword,
      RoutePaths.forgotPassword,
      RoutePaths.resetPassword,
      // onboarding / profile setup
      RoutePaths.createUserInfo,
      '/welcome',
      '/sports_selection',
      '/intent_selection',
      '/sports-selection',
      '/intent-selection',
      RoutePaths.setPassword,
      '/set-password',
      '/create-user-info',
      // demos (treated as public/auth-like so we don't lock user out if already logged in)
      '/design_system_demo',
      '/design-system-demo',
      '/design system demo',
    };

    final loc = state.matchedLocation;
    final isOnAuthPage = authPaths.contains(loc);

    // If not authenticated and not guest, force to login (except splash)
    if (!isAuthenticated && !isGuest && !isOnAuthPage && loc != RoutePaths.splash) {
      if (kDebugMode && _routeLogging) debugPrint('🔁 redirect -> login');
      return RoutePaths.login;
    }

    // If authenticated or guest and on auth page (except welcome), go home
    if ((isAuthenticated || isGuest) && isOnAuthPage && loc != '/welcome') {
      if (kDebugMode && _routeLogging) debugPrint('🔁 redirect -> home');
      return RoutePaths.home;
    }

    return null;
  }

  // Route Definitions
  static List<RouteBase> get _routes => [
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '${RoutePaths.error}:message',
          name: RouteNames.error,
          builder: (context, state) {
            final message = state.pathParameters['message'];
            return ErrorPage(message: message);
          },
        ),
        // Auth Routes
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RoutePaths.enterPassword,
          name: RouteNames.enterPassword,
          builder: (context, state) {
            final extra = state.extra;
            final email = extra is String
                ? extra
                : (extra is Map && extra['email'] is String ? extra['email'] as String : '');
            return EnterPasswordScreen(email: email);
          },
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          name: RouteNames.resetPassword,
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.createUserInfo,
          name: RouteNames.createUserInfo,
          builder: (context, state) {
            final extra = state.extra;
            String email = '';
            bool forceNew = false;
            if (extra is String) {
              email = extra;
            } else if (extra is Map) {
              if (extra['email'] is String) email = extra['email'] as String;
              if (extra['forceNew'] is bool) forceNew = extra['forceNew'] as bool;
            }
            return CreateUserInformation(email: email, forceNew: forceNew);
          },
        ),
        // Design System Demo (public)
        GoRoute(
          path: '/design_system_demo',
          builder: (context, state) => const DesignSystemDemo(),
        ),
        // Aliases for convenience; redirect to the canonical path
        GoRoute(
          path: '/design-system-demo',
          redirect: (context, state) => '/design_system_demo',
        ),
        GoRoute(
          path: '/design system demo',
          redirect: (context, state) => '/design_system_demo',
        ),
        GoRoute(
          path: '/sports_selection',
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return SportsSelectionScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: '/sports-selection',
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return SportsSelectionScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: '/intent_selection',
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return IntentSelectionScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: '/intent-selection',
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return IntentSelectionScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: RoutePaths.setPassword,
          name: RouteNames.setPassword,
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return SetPasswordScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: '/set-password',
          builder: (context, state) {
            final extra = state.extra;
            final reg = extra is Map<String, dynamic>
                ? RegistrationData.fromMap(extra)
                : null;
            return SetPasswordScreen(registrationData: reg);
          },
        ),
        GoRoute(
          path: '/create-user-info',
          builder: (context, state) {
            final extra = state.extra;
            String email = '';
            bool forceNew = false;
            if (extra is String) {
              email = extra;
            } else if (extra is Map) {
              if (extra['email'] is String) email = extra['email'] as String;
              if (extra['forceNew'] is bool) forceNew = extra['forceNew'] as bool;
            }
            return CreateUserInformation(email: email, forceNew: forceNew);
          },
        ),
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) {
            print('🔍 [DEBUG] Welcome route matched! Extra: ${state.extra}');
            final extra = state.extra;
            final displayName = extra is String
                ? extra
                : (extra is Map && extra['displayName'] is String ? extra['displayName'] as String : 'Player');
            print('🔍 [DEBUG] Display name resolved: $displayName');
            return WelcomeScreen(displayName: displayName);
          },
        ),
        // Test route to verify router is working
        GoRoute(
          path: '/test-welcome',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('Test Welcome Route Works!')),
          ),
        ),
        
        // ====================
        // GAMES FEATURE ROUTES
        // ====================
        
        // Main Games Routes
        GoRoute(
          path: '/games',
          name: 'games',
          builder: (context, state) => const SizedBox(), // TODO: wire GamesHomeScreen
          routes: [
            GoRoute(
              path: 'available',
              name: 'available-games',
              builder: (context, state) => const SizedBox(), // TODO
            ),
            GoRoute(
              path: 'my-games',
              name: 'my-games',
              builder: (context, state) => const SizedBox(), // TODO
            ),
            GoRoute(
              path: 'history',
              name: 'game-history',
              builder: (context, state) => const SizedBox(), // TODO
            ),
          ],
        ),

        // Game Detail Routes (with deep linking)
        GoRoute(
          path: '/games/:gameId',
          name: 'game-detail',
          builder: (context, state) => const SizedBox(), // TODO: wire GameDetailScreen
          routes: [
            GoRoute(
              path: 'join',
              name: 'join-game',
              pageBuilder: (context, state) => const MaterialPage(child: SizedBox()), // TODO
            ),
            GoRoute(
              path: 'checkin',
              name: 'game-checkin',
              builder: (context, state) => const SizedBox(), // TODO
            ),
            GoRoute(
              path: 'lobby',
              name: 'game-lobby',
              builder: (context, state) => const SizedBox(), // TODO
            ),
            GoRoute(
              path: 'live',
              name: 'live-game',
              builder: (context, state) => const SizedBox(), // TODO
            ),
            GoRoute(
              path: 'post-game',
              name: 'post-game',
              builder: (context, state) => const SizedBox(), // TODO
            ),
          ],
        ),

        // Game Creation Flow (single entrypoint hosting the whole wizard)
        GoRoute(
          path: '/create-game',
          name: 'create-game',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CreateGameScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        // Legacy camelCase route alias (cleanup: remove once all references updated)
        GoRoute(
          path: '/gameCreate',
          redirect: (context, state) => '/create-game',
        ),
        // Backward compatibility: redirect old entrypoint to the new one
        GoRoute(
          path: '/create-game/basic-info',
          name: 'create-game-basic-info',
          redirect: (context, state) => '/create-game',
        ),
        GoRoute(
          path: '/create-game/venue-selection',
          name: 'create-game-venue-selection',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGameVenueSelectionScreen(),
            transitionsBuilder: _modalTransition,
          ),
        ),
        GoRoute(
          path: '/create-game/date-time',
          name: 'create-game-date-time',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGameDateTimeScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/create-game/player-settings',
          name: 'create-game-player-settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGamePlayerSettingsScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/create-game/pricing',
          name: 'create-game-pricing',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGamePricingScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/create-game/additional-details',
          name: 'create-game-additional-details',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGameAdditionalDetailsScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/create-game/review',
          name: 'create-game-review',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SizedBox(), // CreateGameReviewScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Venue Routes
        GoRoute(
          path: '/venues',
          name: 'venues-list',
          builder: (context, state) => const SizedBox(), // TODO: VenuesListScreen
        ),
        GoRoute(
          path: '/venues/:venueId',
          name: 'venue-detail',
          builder: (context, state) => const SizedBox(), // TODO: VenueDetailScreen
        ),
        
        // Add more routes here...
      ];

  // Custom Transition Builders
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  }

  static Widget _modalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // Route Guard for Game Organizer Actions
  // (Removed unused _requiresGameOrganizerAuth helper to satisfy lints.)
}

/// Navigation Helper Methods
extension NavigationExtension on BuildContext {
  /// Navigate to the home page
  void navigateToHome() => goNamed(RouteNames.home);

  /// Navigate to the error page
  void navigateToError(String message) => goNamed(
        RouteNames.error,
        pathParameters: {'message': message},
      );

  /// Navigate back if possible, otherwise go to home
  void navigateBack() {
    if (canPop()) {
      pop();
    } else {
      goNamed(RouteNames.home);
    }
  }

  // Game Navigation Methods
  void navigateToGames() => go('/games');
  void navigateToAvailableGames() => go('/games/available');
  void navigateToMyGames() => go('/games/my-games');
  void navigateToGameHistory() => go('/games/history');
  
  void navigateToGameDetail(String gameId) => go('/games/$gameId');
  void navigateToJoinGame(String gameId) => go('/games/$gameId/join');
  void navigateToGameCheckin(String gameId) => go('/games/$gameId/checkin');
  void navigateToGameLobby(String gameId) => go('/games/$gameId/lobby');
  void navigateToLiveGame(String gameId) => go('/games/$gameId/live');
  void navigateToPostGame(String gameId) => go('/games/$gameId/post-game');
  
  void navigateToCreateGame() => go('/create-game');
  void navigateToCreateGameVenueSelection() => go('/create-game/venue-selection');
  void navigateToCreateGameDateTime() => go('/create-game/date-time');
  void navigateToCreateGamePlayerSettings() => go('/create-game/player-settings');
  void navigateToCreateGamePricing() => go('/create-game/pricing');
  void navigateToCreateGameAdditionalDetails() => go('/create-game/additional-details');
  void navigateToCreateGameReview() => go('/create-game/review');
  
  void navigateToVenuesList() => go('/venues');
  void navigateToVenueDetail(String venueId) => go('/venues/$venueId');
}

// Custom Transition Page
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}
