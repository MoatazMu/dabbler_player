import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';

class LoginFormState {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;
  final AuthSession? session;
  final User? user;
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
    this.session,
    this.user,
  });

  LoginFormState copyWith({String? email, String? password, bool? isLoading, String? error, AuthSession? session, User? user}) => LoginFormState(
    email: email ?? this.email,
    password: password ?? this.password,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    session: session ?? this.session,
    user: user ?? this.user,
  );
}

class LoginController extends StateNotifier<LoginFormState> {
  final LoginUseCase loginUseCase;
  LoginController(this.loginUseCase) : super(const LoginFormState());

  Future<void> login() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await loginUseCase(LoginParams(email: state.email, password: state.password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (session) => state = state.copyWith(isLoading: false, session: session, error: null),
    );
  }

  void setLoading(bool value) => state = state.copyWith(isLoading: value);
  void updateEmail(String email) => state = state.copyWith(email: email);
  void updatePassword(String password) => state = state.copyWith(password: password);
}
