import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String preferredLanguage;
  final bool phoneVerified;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.preferredLanguage = 'ar',
    this.phoneVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
        avatar: json['avatar'] as String?,
        preferredLanguage: json['preferred_language'] as String? ?? 'ar',
        phoneVerified: json['phone_verified_at'] != null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar': avatar,
        'preferred_language': preferredLanguage,
        'phone_verified_at': phoneVerified ? DateTime.now().toIso8601String() : null,
      };

  @override
  List<Object?> get props => [id, name, phone, email, avatar];
}
