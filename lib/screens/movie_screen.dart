import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/movie.dart';
import '../mocks/mock_data.dart';
import '../theme/design_tokens.dart';
import '../widgets/movie_card.dart';

class MovieScreen extends StatefulWidget {
  final void Function(Movie movie, String heroTag) onMovieTap;

  const MovieScreen({super.key, required this.onMovieTap});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  String _query = '';
  int _selectedFilter = 0;

  List<Movie> get _filteredMovies {
    final selectedSet = _selectedFilter == 0
        ? nowPlayingMovies
        : _selectedFilter == 1
        ? comingSoonMovies
        : allMovies;
    if (_query.isEmpty) return selectedSet;
    return selectedSet
        .where(
          (movie) =>
              movie.title.toLowerCase().contains(_query.toLowerCase()) ||
              movie.genre.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm phim, thể loại, suất hot...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                  ),
                ),
                onChanged: (value) => setState(() {
                  _query = value;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _chip('Đang chiếu', 0),
                  _chip('Sắp chiếu', 1),
                  _chip('Tất cả', 2),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${_filteredMovies.length} phim',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlphaPercent(0.64),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _filteredMovies.isEmpty
                    ? Center(
                        child: Text(
                          'Không có phim phù hợp với từ khóa hiện tại.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMovies.length,
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (_, index) {
                          final movie = _filteredMovies[index];
                          return MovieCard(
                            movie: movie,
                            heroTag: 'browse-${movie.id}',
                            onTap: () =>
                                widget.onMovieTap(movie, 'browse-${movie.id}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).cardTheme.color,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
