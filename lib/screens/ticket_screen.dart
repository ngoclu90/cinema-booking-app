import 'package:flutter/material.dart';

import '../components/ticket/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../mocks/mock_data.dart';
import '../models/ticket.dart';

enum _TicketFilter { upcoming, watched, canceled }

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with AutomaticKeepAliveClientMixin<TicketScreen> {
  bool _loading = true;
  Object? _error;
  _TicketFilter _filter = _TicketFilter.upcoming;
  List<Ticket> _tickets = const <Ticket>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  List<Ticket> get _filteredTickets {
    return switch (_filter) {
      _TicketFilter.upcoming =>
        _tickets
            .where((ticket) => ticket.status != 'Đã hủy')
            .toList(growable: false),
      _TicketFilter.watched => const <Ticket>[],
      _TicketFilter.canceled =>
        _tickets
            .where((ticket) => ticket.status == 'Đã hủy')
            .toList(growable: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScreenContainer(
      title: 'Vé của tôi',
      subtitle: 'Theo dõi vé sắp tới và lịch sử',
      onRefresh: _load,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Column(
        key: ValueKey('ticket-loading'),
        children: [
          AppSkeletonBox(height: 44),
          SizedBox(height: AppSpacing.md),
          AppSkeletonList(itemCount: 4),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('ticket-error'),
        title: 'Không tải được vé',
        message: 'Hãy thử lại để cập nhật vé của bạn.',
        onRetry: _load,
      );
    }

    final items = _filteredTickets;

    return Column(
      key: const ValueKey('ticket-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TicketTabs(
          selected: _filter,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (items.isEmpty)
          AppEmptyState(
            title: _emptyTitle,
            message: _emptyMessage,
            icon: Icons.receipt_long_outlined,
          )
        else
          ...items.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TicketCard(ticket: ticket),
            ),
          ),
      ],
    );
  }

  String get _emptyTitle {
    return switch (_filter) {
      _TicketFilter.upcoming => 'Chưa có vé nào',
      _TicketFilter.watched => 'Chưa có vé đã xem',
      _TicketFilter.canceled => 'Chưa có vé đã hủy',
    };
  }

  String get _emptyMessage {
    return switch (_filter) {
      _TicketFilter.upcoming => 'Vé đã đặt sẽ xuất hiện tại đây.',
      _TicketFilter.watched => 'Lịch sử xem phim sẽ được cập nhật sau.',
      _TicketFilter.canceled => 'Vé đã hủy sẽ được lưu tại đây.',
    };
  }
}

class _TicketTabs extends StatelessWidget {
  final _TicketFilter selected;
  final ValueChanged<_TicketFilter> onChanged;

  const _TicketTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TicketTab(
          label: 'Sắp tới',
          selected: selected == _TicketFilter.upcoming,
          onPressed: () => onChanged(_TicketFilter.upcoming),
        ),
        const SizedBox(width: AppSpacing.sm),
        _TicketTab(
          label: 'Đã xem',
          selected: selected == _TicketFilter.watched,
          onPressed: () => onChanged(_TicketFilter.watched),
        ),
        const SizedBox(width: AppSpacing.sm),
        _TicketTab(
          label: 'Đã hủy',
          selected: selected == _TicketFilter.canceled,
          onPressed: () => onChanged(_TicketFilter.canceled),
        ),
      ],
    );
  }
}

class _TicketTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _TicketTab({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.brandPrimary
                : AppColors.bgSurface2,
            side: BorderSide(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.borderDefault,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionStrong.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
