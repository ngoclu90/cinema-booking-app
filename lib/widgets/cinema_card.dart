import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/cinema.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';

class CinemaCard extends StatelessWidget {
  final Cinema cinema;

  const CinemaCard({super.key, required this.cinema});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final baseColor = AppTheme.surfaceLayer(context, level: 1);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        gradient: LinearGradient(
          colors: [
            baseColor,
            Color.lerp(baseColor, cinema.accent, isDark ? 0.12 : 0.05)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlphaPercent(isDark ? 0.28 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: -10,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/logo_cinema_mark.png',
                width: 110,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cinema.accent.withAlphaPercent(
                        isDark ? 0.18 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.locationDot,
                      color: cinema.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cinema.name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: cinema.accent.withAlphaPercent(
                              isDark ? 0.18 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${cinema.status} · ${cinema.distance}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: cinema.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                cinema.address,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                cinema.landmark,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlphaPercent(0.68),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoLine(icon: FontAwesomeIcons.phone, text: cinema.phone),
              const SizedBox(height: AppSpacing.sm),
              _InfoLine(
                icon: FontAwesomeIcons.clock,
                text: '${cinema.operatingHours} · ${cinema.halls} phòng chiếu',
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cinema.facilities
                    .map(
                      (facility) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLayer(context, level: 2),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          facility,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppNotifier.info(
                          context,
                          title: 'Chỉ đường',
                          description:
                              'Bạn có thể mở bản đồ để xem đường đi đến rạp.',
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 14,
                      ),
                      label: const Text('Chỉ đường'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AppNotifier.success(
                          context,
                          title: 'Đã lưu rạp',
                          description:
                              '${cinema.name} đã được thêm vào danh sách yêu thích.',
                        );
                      },
                      icon: const FaIcon(FontAwesomeIcons.ticket, size: 14),
                      label: const Text('Đặt vé'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final FaIconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.66),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
