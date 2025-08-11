import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository_provider.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(
    repository: repository,
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
  );
});

final loginControllerProvider = StateNotifierProvider<LoginController, LoginFormState>((ref) {
  return LoginController(ref.watch(loginUseCaseProvider));
});

final registerControllerProvider = StateNotifierProvider<RegisterController, RegisterFormState>((ref) {
  return RegisterController(ref.watch(registerUseCaseProvider));
});

final currentUserProvider = Provider((ref) => ref.watch(authControllerProvider).user);
final isAuthenticatedProvider = Provider((ref) => ref.watch(authControllerProvider).isAuthenticated);

// Guest mode state
final isGuestProvider = StateProvider<bool>((ref) => false);

// Use Case Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});
