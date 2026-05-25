// lib/domain/entities/user_entity.dart
class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // Untuk customer nilainya bernilai 'customer'

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });
}