// lib/presentation/features/auth/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.checkCurrentSession();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> loginWithEmail({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.loginWithEmail(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      emit(Unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(const AuthLoading());
    try {
      await _repository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await _repository.logout();
      emit(const RegisterSuccess());
    } catch (e) {
      emit(Unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await _repository.logout();
    emit(const Unauthenticated());
  }
}