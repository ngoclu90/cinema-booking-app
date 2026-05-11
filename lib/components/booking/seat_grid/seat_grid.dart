import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../seat_item/seat_item.dart';

class SeatGrid extends StatelessWidget {
  final List<List<String?>> blueprint;
  final Set<String> selectedSeats;
  final Set<String> bookedSeats;
  final Set<String> vipSeats;
  final Set<String> coupleSeats;
  final ValueChanged<String> onSeatPressed;

  const SeatGrid({
    super.key,
    required this.blueprint,
    required this.selectedSeats,
    required this.bookedSeats,
    this.vipSeats = const <String>{},
    this.coupleSeats = const <String>{},
    required this.onSeatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rowLabelWidth = 22.0;
        const gap = 6.0;
        final seatSlots = blueprint.fold<int>(0, (maxSlots, row) {
          var slots = 0;
          for (final seat in row) {
            if (seat == null) {
              slots += 1;
              continue;
            }
            slots += coupleSeats.contains(seat) ? 2 : 1;
          }
          return slots > maxSlots ? slots : maxSlots;
        });
        final seatGaps = blueprint.fold<int>(0, (maxGaps, row) {
          final gaps = row.whereType<String>().length;
          return gaps > maxGaps ? gaps : maxGaps;
        });
        final seatSize =
            ((constraints.maxWidth - rowLabelWidth - (seatGaps * gap)) /
                    (seatSlots == 0 ? 1 : seatSlots))
                .clamp(28.0, 36.0);

        return Column(
          children: blueprint
              .map((row) {
                final rowLabel = row.whereType<String>().first.substring(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: rowLabelWidth,
                        child: Text(
                          rowLabel,
                          style: AppTypography.captionStrong.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: gap),
                      ...row.map((seat) {
                        if (seat == null) {
                          return SizedBox(width: seatSize * 0.72);
                        }
                        final isCouple = coupleSeats.contains(seat);
                        return Padding(
                          padding: const EdgeInsets.only(right: gap),
                          child: SizedBox(
                            width: isCouple ? (seatSize * 2) : seatSize,
                            height: seatSize,
                            child: SeatItem(
                              code: seat,
                              status: _statusFor(seat),
                              onPressed: () => onSeatPressed(seat),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  SeatStatus _statusFor(String seat) {
    if (bookedSeats.contains(seat)) return SeatStatus.booked;
    if (selectedSeats.contains(seat)) return SeatStatus.selected;
    if (vipSeats.contains(seat)) return SeatStatus.vip;
    if (coupleSeats.contains(seat)) return SeatStatus.couple;
    return SeatStatus.available;
  }
}
