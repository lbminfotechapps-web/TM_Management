import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<UserEntity> login(
    String email,
    String password,
  ) {
    return localDataSource.login(email, password);
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return localDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() {
    return localDataSource.logout();
  }
}