import 'package:cine_sphere/models/auth_session.dart';
import 'package:cine_sphere/screens/login_screen.dart';
import 'package:cine_sphere/screens/main_screen.dart';
import 'package:cine_sphere/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  late Future<AuthSession?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _authService.restoreSession();
  }

  void _setSession(AuthSession? session) {
    setState(() {
      _sessionFuture = Future.value(session);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A1424),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;
        if (session == null) {
          return LoginScreen(
            authService: _authService,
            onAuthenticated: _setSession,
          );
        }

        return MainScreen(
          session: session,
          authService: _authService,
          onLoggedOut: () => _setSession(null),
        );
      },
    );
  }
}
