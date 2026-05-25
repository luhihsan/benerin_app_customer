// lib/data/datasources/auth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({required String email, required String password});
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
  Future<UserModel?> getCurrentUserData() async {
    // Alur penantian sinkronisasi session token lokal HP
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
    if (!doc.exists) throw Exception('Data profil pengguna tidak terdaftar di Firestore.');
    return UserModel.fromMap(doc.id, doc.data()!);
  }
}