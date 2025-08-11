import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class LoginUseCase extends UseCase<Either<Failure, AuthSession>, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) async {
    if (params.email.isEmpty || params.password.isEmpty) {
      return Left(AuthFailure('Email and password must not be empty'));
    }
    return repository.signInWithEmail(email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}
