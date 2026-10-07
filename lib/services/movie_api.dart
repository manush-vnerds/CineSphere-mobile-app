import 'dart:convert';

import 'package:cine_sphere/models/Movie.dart';
import 'package:http/http.dart' as http;

class MovieApi {
  MovieApi._();

  static const _baseUrl =
      'https://cinesphere-movie-ticket-booking-backend.onrender.com/';

  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('${_baseUrl}movies'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final moviesResponse = MoviesResponse.fromJson(responseJson);

    if (!moviesResponse.success) {
      throw Exception('The server did not return a successful response.');
    }

    return moviesResponse.movies;
  }

  static Future<List<MovieSuggestion>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}search/${Uri.encodeComponent(query)}'),
    );

    if (response.statusCode != 200) {
      throw Exception('Movie search failed: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final movies = responseJson['movies'] as List<dynamic>? ?? const [];

    return movies
        .map((movie) => MovieSuggestion.fromJson(movie as Map<String, dynamic>))
        .toList();
  }

  static Future<Movie> fetchMovieById(String movieId) async {
    final response = await http.get(Uri.parse('${_baseUrl}movies/$movieId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load movie details: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final data = responseJson['data'];

    if (data is List && data.isNotEmpty) {
      return Movie.fromJson(data.first as Map<String, dynamic>);
    }

    if (data is Map<String, dynamic>) {
      return Movie.fromJson(data);
    }

    throw Exception('Movie details were not found.');
  }

  static Future<List<MovieReview>> fetchReviews(String movieId) async {
    final response = await http.get(Uri.parse('${_baseUrl}revies/$movieId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final reviews = responseJson['review'] as List<dynamic>? ?? const [];

    return reviews
        .map((review) => MovieReview.fromJson(review as Map<String, dynamic>))
        .toList();
  }
}
