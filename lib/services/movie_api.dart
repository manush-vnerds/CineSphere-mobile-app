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
        .map(
          (movie) => MovieSuggestion.fromJson(movie as Map<String, dynamic>),
        )
        .toList();
  }
}
