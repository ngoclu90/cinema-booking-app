import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/tokens/index.dart';
import '../../../models/ticket.dart';
import '../../ui/index.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    String timeStr = '';
    try {
      if (ticket.showTime.isNotEmpty) {
        final parsedDate = DateTime.parse(ticket.showTime).toLocal();
        dateStr = DateFormat('dd/MM/yyyy').format(parsedDate);
        timeStr = DateFormat('HH:mm').format(parsedDate);
      }
    } catch (_) {
      dateStr = ticket.showTime;
      timeStr = '--:--';
    }

    final formattedPrice = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(ticket.totalPrice);

    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.brandPrimary),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: AppColors.textPrimary,
                  size: 34,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.movieTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ticket.cinemaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: ticket.status,
                backgroundColor: AppColors.brandPrimarySoft,
                foregroundColor: AppColors.textPrimary,
                borderColor: AppColors.brandPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppDivider(),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: dateStr, icon: const Icon(Icons.event, size: 14)),
              AppBadge(label: timeStr, icon: const Icon(Icons.schedule, size: 14)),
              AppBadge(
                label: ticket.roomName,
                icon: const Icon(Icons.meeting_room_outlined, size: 14),
              ),
              AppBadge(label: ticket.seatCodes, icon: const Icon(Icons.event_seat, size: 14)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đưa mã này cho nhân viên soát vé',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formattedPrice,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}