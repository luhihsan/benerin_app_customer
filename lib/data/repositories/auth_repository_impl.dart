// lib/data/repositories/auth_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart'; // Import kontrak domain yang benar
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> loginWithEmail({required String email, required String password}) async {
    final model = await _remoteDataSource.signInWithEmail(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final model = await _remoteDataSource.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return model.toEntity();
  }

  @override
  Future<UserEntity?> checkCurrentSession() async {
    final model = await _remoteDataSource.getCurrentUserData();
    return model?.toEntity();
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.signOut();
  }
}