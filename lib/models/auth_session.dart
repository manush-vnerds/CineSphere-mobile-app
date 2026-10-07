class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.isAdmin,
  });

  final String token;
  final String userId;
  final String email;
  final bool isAdmin;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }
}
