part of 'auth_bloc.dart';



sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequestedEvent extends AuthEvent {}