part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message = '',
  });

  @override
  List<Object?> get props => [status, user, message];
}