import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../../models/cinema.dart';
import '../../../models/showtime.dart';
import '../../ui/index.dart';
import '../showtime_button/showtime_button.dart';

class CinemaCard extends StatelessWidget {
  final Cinema cinema;
  final List<Showtime> showtimes;
  final Showtime? selectedShowtime;
  final ValueChanged<Showtime>? onShowtimeSelected;

  const CinemaCard({
    super.key,
    required this.cinema,
    this.showtimes = const <Showtime>[],
    this.selectedShowtime,
    this.onShowtimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.brandPrimary,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      cinema.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(label: cinema.distance, icon: const Icon(Icons.near_me)),
              AppBadge(
                label: cinema.operatingHours,
                icon: const Icon(Icons.schedule),
              ),
              AppBadge(
                label: '${cinema.halls} phòng',
                icon: const Icon(Icons.meeting_room_outlined),
              ),
            ],
          ),
          if (showtimes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: showtimes
                  .map(
                    (showtime) => ShowtimeButton(
                      time: showtime.time,
                      selected: selectedShowtime?.id == showtime.id,
                      onPressed: () => onShowtimeSelected?.call(showtime),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
