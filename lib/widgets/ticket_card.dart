import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final isDark = context.isDarkMode;
    final baseColor = AppTheme.surfaceLayer(context, level: 1);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        gradient: LinearGradient(
          colors: [
            Color.lerp(baseColor, statusColor, isDark ? 0.10 : 0.05)!,
            baseColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlphaPercent(isDark ? 0.30 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket.movieTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlphaPercent(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  ticket.status,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${ticket.cinemaName} · ${ticket.hallType} · ${ticket.screen}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ticketDetail(context, 'Ghế', ticket.seat),
              _ticketDetail(context, 'Ngày', ticket.date),
              _ticketDetail(context, 'Giờ', ticket.time),
              _ticketDetail(context, 'Cổng', ticket.gate),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(
              14,
              (_) => Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.ticketCode,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ticket.snackCombo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.66),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      ticket.qrHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.56),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                ticket.price,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 26),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppNotifier.info(
                      context,
                      title: 'Đã tạo nhắc lịch xem',
                      description: 'Bạn sẽ nhận thông báo trước giờ chiếu.',
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.bell, size: 14),
                  label: const Text('Nhắc lịch'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppNotifier.success(
                      context,
                      title: 'Đã lưu vé',
                      description: 'Vé đã được lưu để bạn mở lại nhanh hơn.',
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.wallet, size: 14),
                  label: const Text('Ví vé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ticketDetail(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLayer(context, level: 2),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.62),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã xác nhận':
        return const Color(0xFF10B981);
      case 'giữ chỗ':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.brandRed;
    }
  }
}
