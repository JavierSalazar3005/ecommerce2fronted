import 'role.dart';

class AuthResponse {
  final int userId;
  final String email;
  final Role role;
  final String? companyName;
  final String token;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.role,
    this.companyName,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as int,
      email: json['email'] as String,
      role: Role.fromInt(json['role'] as int),
      companyName: json['companyName'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'role': role.value,
      'companyName': companyName,
      'token': token,
    };
  }
}
