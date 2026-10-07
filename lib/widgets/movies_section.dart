import 'package:cine_sphere/models/Movie.dart';
import 'package:cine_sphere/services/movie_api.dart';
import 'package:flutter/material.dart';

class MoviesSection extends StatefulWidget {
  const MoviesSection({
    super.key,
    required this.searchQuery,
    required this.onMovieSelected,
  });

  final String searchQuery;
  final ValueChanged<Movie> onMovieSelected;

  @override
  State<MoviesSection> createState() => _MoviesSectionState();
}

class _MoviesSectionState extends State<MoviesSection> {
  late final Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = MovieApi.fetchMovies();
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    final query = widget.searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return movies;
    }

    return movies.where((movie) {
      return movie.title.toLowerCase().contains(query) ||
          movie.genres.any((genre) => genre.toLowerCase().contains(query)) ||
          movie.cast.any((actor) => actor.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final movies = _filterMovies(snapshot.data ?? const []);

        if (movies.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No movies found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MovieCard(
                movie: movies[index],
                onTap: () => widget.onMovieSelected(movies[index]),
              ),
              childCount: movies.length,
            ),
          ),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  static const _imageBaseUrl =
      'https://cinesphere-movie-ticket-booking-backend.onrender.com/';

  @override
  Widget build(BuildContext context) {
    final normalizedPath = movie.imagePath.replaceAll('\\', '/');
    final imageUrl = Uri.encodeFull('$_imageBaseUrl$normalizedPath');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF15243A),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 165,
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        movie.genres.join(' / '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFAAB7C8)),
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
                            '${movie.rating.toStringAsFixed(1)}/5',
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
                            style: const TextStyle(color: Color(0xFFAAB7C8)),
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
  }
}
