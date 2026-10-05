import 'package:cine_sphere/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CineShpere"),
        backgroundColor: const Color.fromARGB(255, 145, 138, 138),
        actions: [
          IconButton(
            onPressed: () => {print("Profile prassed")},
            icon: const Icon(Icons.person),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "Admin",
          ),
        ],
      ),
    );
  }
}
