import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';
import '../widgets/accent_button.dart';
import 'booking_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final String heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  movie.accent,
                  Color.lerp(movie.accent, Colors.black, 0.72)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox.expand(),
          ),
          Positioned(
            top: 86,
            right: -32,
            child: Opacity(
              opacity: 0.14,
              child: Image.asset(
                'assets/images/logo_cinema_mark.png',
                width: 220,
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 76),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.hero),
                          color: Colors.white.withAlphaPercent(0.12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlphaPercent(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              movie.headline,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withAlphaPercent(0.82),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _detailBadge(movie.duration),
                                _detailBadge(
                                  '${movie.rating.toStringAsFixed(1)}/10 đánh giá',
                                ),
                                _detailBadge(movie.language),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.hero),
                      topRight: Radius.circular(AppRadius.hero),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoTile(
                            label: 'Thể loại',
                            value: movie.genre,
                            icon: FontAwesomeIcons.film,
                          ),
                          _InfoTile(
                            label: 'Đạo diễn',
                            value: movie.director,
                            icon: FontAwesomeIcons.circleInfo,
                          ),
                          _InfoTile(
                            label: 'Khởi chiếu',
                            value: movie.releaseDate,
                            icon: FontAwesomeIcons.calendarDays,
                          ),
                          _InfoTile(
                            label: 'Định dạng',
                            value: movie.formats.join(' · '),
                            icon: FontAwesomeIcons.ticket,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Nội dung phim',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        movie.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Điểm nhấn đặt vé',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: movie.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLayer(
                                    context,
                                    level: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Suất chiếu nhanh',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: movie.showtimes
                            .map(
                              (showtime) => Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLayer(
                                    context,
                                    level: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.card,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      showtime.time,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${showtime.dateLabel} · ${showtime.screen} · ${showtime.price}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlphaPercent(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${showtime.format} · ${showtime.availability}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        movie.bookingHint,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlphaPercent(0.72),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: AccentButton(
                              label: 'Đặt vé',
                              leading: const FaIcon(
                                FontAwesomeIcons.ticket,
                                size: 14,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final showtime = movie.showtimes.isNotEmpty
                                    ? movie.showtimes.first
                                    : null;
                                if (showtime == null) {
                                  AppNotifier.warning(
                                    context,
                                    title: 'Chưa có suất chiếu',
                                    description:
                                        'Phim này hiện chưa có suất chiếu khả dụng.',
                                  );
                                  return;
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingScreen(
                                      movie: movie,
                                      showtime: showtime,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AccentButton(
                              label: 'Chia sẻ',
                              reversed: true,
                              leading: FaIcon(
                                FontAwesomeIcons.arrowUpFromBracket,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                AppNotifier.info(
                                  context,
                                  title: 'Chia sẻ phim',
                                  description:
                                      'Bạn có thể chia sẻ phim này với bạn bè.',
                                );
                              },
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
        ],
      ),
    );
  }

  Widget _detailBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final FaIconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLayer(context, level: 1),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.62),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
