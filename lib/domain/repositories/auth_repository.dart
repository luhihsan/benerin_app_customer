// lib/domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Melakukan otentikasi masuk menggunakan email dan kata sandi.
  Future<UserEntity> loginWithEmail({required String email, required String password});

  /// Mendaftarkan akun pelanggan baru ke Firebase Auth dan Cloud Firestore.
  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  /// Memeriksa keberadaan sesi login aktif di dalam penyimpanan lokal perangkat.
  Future<UserEntity?> checkCurrentSession();

  /// Memutuskan sesi login aktif dan keluar dari aplikasi.
  Future<void> logout();
}