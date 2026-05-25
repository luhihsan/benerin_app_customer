// lib/presentation/features/auth/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  // Setelan awal diarahkan ke posisi memuat untuk memeriksa token session internal HP
  AuthCubit(this._repository) : super(const AuthInitial());

  /// Memeriksa eksistensi token sesi pengguna secara asinkronus (Auto Login System).
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

  /// Mengeksekusi verifikasi otentikasi login email pelanggan.
  Future<void> loginWithEmail({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.loginWithEmail(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      emit(Unauthenticated(errorMessage: e.toString()));
    }
  }

  /// Memutuskan sambungan otentikasi aktif.
  Future<void> logout() async {
    emit(const AuthLoading());
    await _repository.logout();
    emit(const Unauthenticated());
  }
}