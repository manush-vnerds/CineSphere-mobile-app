import 'package:cine_sphere/services/movie_api.dart';
import 'package:cine_sphere/screens/movie_detail_screen.dart';
import 'package:cine_sphere/widgets/movie_search_bar.dart';
import 'package:cine_sphere/widgets/movies_section.dart';
import 'package:cine_sphere/widgets/searchbar_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:cine_sphere/widgets/hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchTermController = TextEditingController();

  @override
  void dispose() {
    _searchTermController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A1424),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HeroSection()),
          SliverPersistentHeader(
            pinned: true,
            delegate: SearchBarHeaderDelegate(
              child: MovieSearchBar(
                controller: _searchTermController,
                onChanged: (_) => setState(() {}),
                searchMovies: MovieApi.searchMovies,
                onSelected: (movie) {
                  _searchTermController.text = movie.title;
                  setState(() {});
                  _openMovieDetails(movie.id);
                },
              ),
            ),
          ),
          MoviesSection(
            searchQuery: _searchTermController.text,
            onMovieSelected: (movie) => _openMovieDetails(movie.id),
          ),
        ],
      ),
    );
  }

  void _openMovieDetails(String movieId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movieId)),
    );
  }
}
