import 'package:cine_sphere/models/auth_session.dart';
import 'package:cine_sphere/screens/home_screen.dart';
import 'package:cine_sphere/services/auth_service.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.session,
    required this.authService,
    required this.onLoggedOut,
  });

  final AuthSession session;
  final AuthService authService;
  final VoidCallback onLoggedOut;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) widget.onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CineShpere"),
        backgroundColor: const Color.fromARGB(255, 145, 138, 138),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                value: 'email',
                child: Text(widget.session.email),
              ),
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: HomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 31, 32, 61),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Offers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support),
            label: "Contact Us",
          ),
          if (widget.session.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}
