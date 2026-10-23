
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/app_exception.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferencesAsync prefs;

  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<UserModel> login(
    String email,
    String password,
  ) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AppException(
        'Please enter email and password',
      );
    }

    final user = UserModel(
      id: '1',
      name: email.split('@').first,
      email: email.trim(),
    );

    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);

    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final id = await prefs.getString('user_id');

    if (id == null) return null;

    return UserModel(
      id: id,
      name: await prefs.getString('user_name') ?? '',
      email: await prefs.getString('user_email') ?? '',
    );
  }

  @override
  Future<void> logout() async {
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}