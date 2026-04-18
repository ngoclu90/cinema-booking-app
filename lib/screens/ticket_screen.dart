import 'package:flutter/material.dart';
import '../mocks/mock_data.dart';
import '../theme/design_tokens.dart';
import '../widgets/ticket_card.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hasTickets = tickets.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              if (!hasTickets)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 72,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlphaPercent(0.35),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Chưa có vé nào được lưu',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Vé đã đặt sẽ xuất hiện ở đây.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tickets.length,
                    itemBuilder: (_, index) {
                      final ticket = tickets[index];
                      return TicketCard(ticket: ticket);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
