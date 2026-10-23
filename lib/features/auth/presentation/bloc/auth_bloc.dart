import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase currentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.currentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState()) {
    on<CheckAuthEvent>(_checkAuth);
    on<LoginRequestedEvent>(_login);
    on<LogoutRequestedEvent>(_logout);
  }

  Future<void> _checkAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final user = await currentUserUseCase(const NoParams());

      emit(AuthState(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _login(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final user = await loginUseCase(
        LoginParams(event.email, event.password),
      );

      emit(AuthState(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _logout(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase(const NoParams());

    emit(const AuthState(
      status: AuthStatus.unauthenticated,
    ));
  }
}