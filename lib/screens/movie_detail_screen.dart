import 'package:cine_sphere/models/Movie.dart';
import 'package:cine_sphere/services/movie_api.dart';
import 'package:flutter/material.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final Future<Movie> _movieFuture;
  late final Future<List<MovieReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = MovieApi.fetchMovieById(widget.movieId);
    _reviewsFuture = MovieApi.fetchReviews(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1424),
      appBar: AppBar(
        title: const Text('Movie Details'),
        backgroundColor: const Color(0xFF0A1424),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Movie>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data;
          if (movie == null) {
            return const Center(
              child: Text(
                'Movie not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MovieBanner(movie: movie),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'About Movie'),
                    const SizedBox(height: 8),
                    Text(
                      movie.description,
                      style: const TextStyle(
                        color: Color(0xFFD2DCE9),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Cast'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.cast
                          .map(
                            (name) => Chip(
                              label: Text(name),
                              labelStyle: const TextStyle(color: Colors.white),
                              backgroundColor: const Color(0xFF15243A),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Reviews'),
                    const SizedBox(height: 12),
                    FutureBuilder<List<MovieReview>>(
                      future: _reviewsFuture,
                      builder: (context, reviewsSnapshot) {
                        if (reviewsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (reviewsSnapshot.hasError) {
                          return const Text(
                            'Reviews could not be loaded.',
                            style: TextStyle(color: Color(0xFFAAB7C8)),
                          );
                        }

                        final reviews = reviewsSnapshot.data ?? const [];
                        if (reviews.isEmpty) {
                          return const Text(
                            'No reviews yet.',
                            style: TextStyle(color: Color(0xFFAAB7C8)),
                          );
                        }

                        return Column(
                          children: reviews
                              .map((review) => _ReviewCard(review: review))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Book Now'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MovieBanner extends StatelessWidget {
  const _MovieBanner({required this.movie});

  final Movie movie;
  static const _baseUrl =
      'https://cinesphere-movie-ticket-booking-backend.onrender.com/';

  @override
  Widget build(BuildContext context) {
    final imagePath = movie.backgroundPosterPath.isNotEmpty
        ? movie.backgroundPosterPath
        : movie.imagePath;
    final imageUrl = Uri.encodeFull(
      '$_baseUrl${imagePath.replaceAll('\\', '/')}',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFF15243A),
                child: Icon(
                  Icons.movie_outlined,
                  color: Colors.white54,
                  size: 72,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xEE0A1424)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${movie.genres.join(' / ')}  |  ${movie.duration} min',
                    style: const TextStyle(color: Color(0xFFD2DCE9)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final MovieReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15243A),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 3),
                Text(
                  '${review.rating}/5',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(color: Color(0xFFD2DCE9)),
            ),
          ],
        ),
      ),
    );
  }
}
