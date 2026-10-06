import 'dart:async';

import 'package:cine_sphere/models/Movie.dart';
import 'package:flutter/material.dart';

class MovieSearchBar extends StatefulWidget {
  const MovieSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.searchMovies,
    required this.onSelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Future<List<MovieSuggestion>> Function(String query) searchMovies;
  final ValueChanged<MovieSuggestion> onSelected;

  @override
  State<MovieSearchBar> createState() => _MovieSearchBarState();
}

class _MovieSearchBarState extends State<MovieSearchBar> {
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<MovieSuggestion> _suggestions = const [];
  bool _isLoading = false;
  int _requestNumber = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    widget.onChanged(value);
    _debounce?.cancel();
    final requestNumber = ++_requestNumber;

    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _suggestions = const [];
      _isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final suggestions = await widget.searchMovies(query);

        if (!mounted || requestNumber != _requestNumber) {
          return;
        }

        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      } catch (error) {
        if (!mounted || requestNumber != _requestNumber) {
          return;
        }

        debugPrint('Movie suggestion search failed: $error');
        setState(() {
          _suggestions = const [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1424),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        child: SizedBox(
          height: 60,
          child: RawAutocomplete<MovieSuggestion>(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            displayStringForOption: (movie) => movie.title,
            optionsBuilder: (_) => _suggestions,
            onSelected: widget.onSelected,
            fieldViewBuilder: (
              context,
              controller,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: _onQueryChanged,
                onSubmitted: (_) => onFieldSubmitted(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Movies, Actors, Genres...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAB7C8),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 30),
                  prefixIconColor: const Color(0xFFD2DCE9),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF0D1E35),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(
                      color: Color(0xFF38536F),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(
                      color: Color(0xFF75A7D8),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              final suggestions = options.toList();

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: const Color(0xFF15243A),
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width - 48,
                      maxHeight: 240,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFF38536F),
                      ),
                      itemBuilder: (context, index) {
                        final movie = suggestions[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.movie_outlined,
                            color: Color(0xFFAAB7C8),
                          ),
                          title: Text(
                            movie.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () => onSelected(movie),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
