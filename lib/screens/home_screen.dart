import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/movie.dart';
import '../mocks/mock_data.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  final void Function(Movie movie, String heroTag) onMovieTap;

  const HomeScreen({super.key, required this.onMovieTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: const SizedBox(height: AppSpacing.sm),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionTitle(
              title: 'Nổi bật',
              actionLabel: 'Xem hết',
              onAction: () {
                AppNotifier.info(
                  context,
                  title: 'Danh sách phim',
                  description: 'Khám phá thêm các phim đang được quan tâm.',
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 276,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.sm,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: featuredMovies.length,
                itemBuilder: (_, index) {
                  final movie = featuredMovies[index];
                  return MovieCard(
                    movie: movie,
                    heroTag: 'featured-${movie.id}',
                    onTap: () => onMovieTap(movie, 'featured-${movie.id}'),
                    compact: true,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionTitle(
              title: 'Đang chiếu',
              actionLabel: 'Nhắc tôi',
              onAction: () {
                AppNotifier.success(
                  context,
                  title: 'Đã bật nhắc lịch',
                  description: 'Bạn sẽ nhận thông báo trước giờ chiếu.',
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, index) {
              final movie = nowPlayingMovies[index];
              return MovieCard(
                movie: movie,
                heroTag: 'now-${movie.id}',
                onTap: () => onMovieTap(movie, 'now-${movie.id}'),
              );
            }, childCount: nowPlayingMovies.length),
          ),
          SliverToBoxAdapter(
            child: SectionTitle(
              title: 'Rạp gần bạn',
              actionLabel: 'Bản đồ',
              onAction: () {
                AppNotifier.info(
                  context,
                  title: 'Danh sách rạp',
                  description: 'Chọn rạp gần bạn để xem lịch chiếu nhanh hơn.',
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 188,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: cinemas.length.clamp(0, 3),
                itemBuilder: (_, index) {
                  final cinema = cinemas[index];
                  return Container(
                    width: 248,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: cinema.accent.withAlphaPercent(0.12),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            cinema.distance,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: cinema.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          cinema.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          cinema.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlphaPercent(0.70),
                              ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.locationDot,
                              size: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cinema.status,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: SectionTitle(title: 'Sắp chiếu')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 248,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.sm,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: comingSoonMovies.length,
                itemBuilder: (_, index) {
                  final movie = comingSoonMovies[index];
                  return MovieCard(
                    movie: movie,
                    heroTag: 'coming-${movie.id}',
                    onTap: () => onMovieTap(movie, 'coming-${movie.id}'),
                    compact: true,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}
