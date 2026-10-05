import 'dart:convert';

import 'package:cine_sphere/models/Movie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviesSection extends StatefulWidget {
  const MoviesSection({super.key});

  @override
  State<MoviesSection> createState() => _MoviesSectionState();
}

class _MoviesSectionState extends State<MoviesSection> {
  final TextEditingController _searchTermController = TextEditingController();

  static const _imageBaseUrl =
      'https://cinesphere-movie-ticket-booking-backend.onrender.com/';

  Future<List<Movie>> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://cinesphere-movie-ticket-booking-backend.onrender.com/movies",
        ),
      );
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        final moviesResponse = MoviesResponse.fromJson(responseJson);

        if (!moviesResponse.success) {
          throw Exception('The server did not return a successful response.');
        }

        return moviesResponse.movies;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Could not load movies: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _searchTermController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: SizedBox(
            height: 60,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Movies, Actors, Genres...',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAB7C8),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 30),
                prefixIconColor: const Color(0xFFD2DCE9),
                filled: true,
                fillColor: const Color(0xFF0D1E35),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Color(0xFF38536F), width: 1.5),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Color(0xFF75A7D8), width: 2),
                ),
              ),
              controller: _searchTermController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),

        Expanded(
          child: Container(
            color: const Color(0xFF0A1424),
            child: FutureBuilder<List<Movie>>(
              future: fetchMovies(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // No data
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No movies found'));
                }

                final movies = snapshot.data;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: movies!.length,

                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      clipBehavior: Clip.antiAlias,
                      color: const Color.fromARGB(255, 21, 36, 58),

                      child: InkWell(
                        onTap: () {},
                        child: SizedBox(
                          height: 165,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 110,
                                height: double.infinity,
                                child: Image.network(
                                  Uri.encodeFull(
                                    '$_imageBaseUrl${movie.imagePath.replaceAll('\\', '/')}',
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const ColoredBox(
                                    color: Color(0xFF263B56),
                                    child: Icon(
                                      Icons.movie_outlined,
                                      color: Colors.white54,
                                      size: 42,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        movie.genres.join(' • '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFAAB7C8),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movie.rating}/5',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.schedule_outlined,
                                            color: Color(0xFFAAB7C8),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movie.duration} min',
                                            style: const TextStyle(
                                              color: Color(0xFFAAB7C8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
