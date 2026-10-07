class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genres,
    required this.imagePath,
    required this.fileName,
    required this.backgroundPosterPath,
    required this.backgroundPosterName,
    required this.cast,
    required this.duration,
    required this.releaseDate,
    required this.description,
    required this.rating,
  });

  final String id;
  final String title;
  final List<String> genres;
  final String imagePath;
  final String fileName;
  final String backgroundPosterPath;
  final String backgroundPosterName;
  final List<String> cast;
  final String duration;
  final DateTime releaseDate;
  final String description;
  final double rating;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      // The API currently uses the key "generes".
      genres: (json['generes'] as List<dynamic>? ?? const [])
          .map((genre) => genre.toString().trim())
          .toList(),
      imagePath: json['imagePath'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      backgroundPosterPath: json['bgPosterPath'] as String? ?? '',
      backgroundPosterName: json['bgPosterName'] as String? ?? '',
      cast: (json['cast'] as List<dynamic>? ?? const [])
          .map((actor) => actor.toString())
          .toList(),
      duration: json['duration']?.toString() ?? '',
      releaseDate:
          DateTime.tryParse(json['releaseDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      // The API currently uses the key "discription".
      description: json['discription'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'generes': genres,
      'imagePath': imagePath,
      'fileName': fileName,
      'bgPosterPath': backgroundPosterPath,
      'bgPosterName': backgroundPosterName,
      'cast': cast,
      'duration': duration,
      'releaseDate': releaseDate.toIso8601String(),
      'discription': description,
      'rating': rating,
    };
  }
}

class MoviesResponse {
  const MoviesResponse({required this.success, required this.movies});

  final bool success;
  final List<Movie> movies;

  factory MoviesResponse.fromJson(Map<String, dynamic> json) {
    return MoviesResponse(
      success: json['success'] as bool? ?? false,
      movies: (json['data'] as List<dynamic>? ?? const [])
          .map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MovieSuggestion {
  const MovieSuggestion({required this.id, required this.title});

  final String id;
  final String title;

  factory MovieSuggestion.fromJson(Map<String, dynamic> json) {
    return MovieSuggestion(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

class MovieReview {
  const MovieReview({
    required this.id,
    required this.movieId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String movieId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map<String, dynamic>?;

    return MovieReview(
      id: json['_id'] as String? ?? '',
      movieId: json['movieId'] as String? ?? '',
      userName: user?['name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
