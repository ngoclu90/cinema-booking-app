import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../seat_item/seat_item.dart';

class SeatGrid extends StatelessWidget {
  final List<List<String?>> blueprint;
  final Set<String> selectedSeats;
  final Set<String> bookedSeats;
  final Set<String> vipSeats;
  final ValueChanged<String> onSeatPressed;

  const SeatGrid({
    super.key,
    required this.blueprint,
    required this.selectedSeats,
    required this.bookedSeats,
    this.vipSeats = const <String>{},
    required this.onSeatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rowLabelWidth = 22.0;
        const gap = 6.0;
        final seatSlots = blueprint.first.length;
        final seatSize =
            ((constraints.maxWidth - rowLabelWidth - (seatSlots * gap)) /
                    seatSlots)
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
                        return Padding(
                          padding: const EdgeInsets.only(right: gap),
                          child: SizedBox(
                            width: seatSize,
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
    return SeatStatus.available;
  }
}
