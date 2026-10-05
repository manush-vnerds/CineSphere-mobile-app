import 'package:cine_sphere/widgets/movies_section.dart';
import 'package:flutter/material.dart';
import 'package:cine_sphere/widgets/hero_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Column(
          children: [
            const HeroSection(),
            Expanded(child: MoviesSection()),
          ],
        ),
      ),
    );
  }
}
