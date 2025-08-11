import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState {
  final User? user;
  final AuthSession? session;
  final bool isLoading;
  final String? error;
  const AuthState({this.user, this.session, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null && session != null;
  AuthState copyWith({User? user, AuthSession? session, bool? isLoading, String? error}) => AuthState(
    user: user ?? this.user,
    session: session ?? this.session,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final GetCurrentUserUseCase getCurrentUser;
  final LogoutUseCase logout;
  late final StreamSubscription<supa.AuthState> _authSub;

  AuthController({required this.repository, required this.getCurrentUser, required this.logout}) : super(const AuthState()) {
    _init();
    // Listen to Supabase auth changes to keep session & user in sync
    _authSub = supa.Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      // Debug
      // print('[AuthController] Auth event: $event session=${session != null}');
      if (event == supa.AuthChangeEvent.signedIn || event == supa.AuthChangeEvent.tokenRefreshed || event == supa.AuthChangeEvent.userUpdated) {
        final supaUser = session?.user ?? supa.Supabase.instance.client.auth.currentUser;
        if (supaUser != null) {
          // Map Supabase user to domain user via repository call (reuse getCurrentUser)
          final userResult = await getCurrentUser(NoParams());
          userResult.fold(
            (_) {},
            (user) {
              state = state.copyWith(user: user, session: session != null ? _convertSession(session, user) : state.session, isLoading: false, error: null);
            },
          );
        }
      }
      if (event == supa.AuthChangeEvent.signedOut) {
        state = const AuthState();
      }
    });
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    // Fetch current user
    final userResult = await getCurrentUser(NoParams());
    userResult.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (user) async {
        // Try to also fetch current session so isAuthenticated can become true
    final sessionResult = await repository.getCurrentSession();
        sessionResult.fold(
          (failure) {
            // We still keep the user; auth may require email confirmation
            // Fallback: attempt direct Supabase session access
      final supaSession = supa.Supabase.instance.client.auth.currentSession;
            if (supaSession != null) {
              state = state.copyWith(user: user, session: _convertSession(supaSession, user), isLoading: false, error: null);
            } else {
              state = state.copyWith(user: user, isLoading: false, error: null);
            }
          },
          (session) {
            state = state.copyWith(user: user, session: session, isLoading: false, error: null);
          },
        );
      },
    );
    // TODO: Listen to Supabase auth changes and update state
    // TODO: Persist auth state across restarts
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final result = await logout(NoParams());
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
  }

  /// Refresh authentication state (useful after signup/signin)
  Future<void> refreshAuthState() async {
    await _init();
  }

  AuthSession _convertSession(supa.Session session, User user) {
    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch((session.expiresAt ?? 0) * 1000),
      user: user,
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
