// lib/data/datasources/auth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> signOut();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) throw Exception('Pengguna tidak ditemukan.');
      return await _fetchUserData(credential.user!.uid);
    } catch (e) {
      throw Exception('Gagal masuk ke sistem: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // 1. Daftarkan kredensial akun ke dalam Firebase Authentication
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw Exception('Gagal membuat kredensial pengguna.');

      final userModel = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'customer', // Mengunci peran pengguna secara mutlak sebagai customer
      );

      // 2. Simpan data profil lengkap ke dalam Cloud Firestore koleksi users
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Gagal mendaftarkan akun baru: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final currentUser = await _firebaseAuth.authStateChanges().first;
    if (currentUser == null) return null;
    return await _fetchUserData(currentUser.uid);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel> _fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Data profil pengguna tidak ditemukan di Firestore.');
    return UserModel.fromMap(doc.id, doc.data()!);
  }
}