import 'dart:convert';

import 'package:cine_sphere/models/auth_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const _baseUrl =
      'https://cinesphere-movie-ticket-booking-backend.onrender.com/';
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _isAdminKey = 'auth_is_admin';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${_baseUrl}login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final session = _parseSession(response);
    await _saveSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${_baseUrl}register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final session = _parseSession(response);
    await _saveSession(session);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userId = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _emailKey);
    final isAdmin = await _storage.read(key: _isAdminKey);

    if (token == null || userId == null || email == null) {
      return null;
    }

    return AuthSession(
      token: token,
      userId: userId,
      email: email,
      isAdmin: isAdmin == 'true',
    );
  }

  Future<Map<String, String>> authorizedHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('${_baseUrl}logout'),
        headers: await authorizedHeaders(),
      );
    } catch (_) {
      // The local session must still be cleared if the server is unreachable.
    } finally {
      await _storage.deleteAll();
    }
  }

  AuthSession _parseSession(http.Response response) {
    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(body['message'] as String? ?? 'Authentication failed.');
    }

    final session = AuthSession.fromJson(body);
    if (session.token.isEmpty || session.userId.isEmpty) {
      throw const AuthException('The server did not return a valid session.');
    }

    return session;
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } on FormatException {
      return const {};
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _isAdminKey, value: '${session.isAdmin}');
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
