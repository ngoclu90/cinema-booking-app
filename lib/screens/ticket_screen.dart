import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/ticket.dart';
import '../data/services/ticket_service.dart';
import '../utils/image_helper.dart'; // Đảm bảo import đúng file ImageHelper của bồ

enum _TicketFilter { upcoming, watched, canceled }

// ==========================================
// 1. MÀN HÌNH CHÍNH (TICKET SCREEN)
// ==========================================
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with AutomaticKeepAliveClientMixin<TicketScreen> {
  final TicketService _ticketService = TicketService();

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
      final data = await _ticketService.getMyTickets();
      if (!mounted) return;
      setState(() {
        _tickets = data ?? const <Ticket>[];
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
    return _tickets.where((ticket) {
      final status = ticket.status.toUpperCase();

      return switch (_filter) {
        _TicketFilter.upcoming =>
        status == 'BOOKED' ||
            status == 'PAID' ||
            status == 'PENDING' ||
            status == 'ĐÃ ĐẶT' ||
            status == 'CONFIRMED',
        _TicketFilter.watched =>
        status == 'COMPLETED' ||
            status == 'WATCHED' ||
            status == 'ĐÃ XEM',
        _TicketFilter.canceled =>
        status == 'CANCELED' ||
            status == 'CANCELLED' ||
            status == 'EXPIRED' ||
            status == 'ĐÃ HỦY',
      };
    }).toList(growable: false);
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
      _TicketFilter.canceled => 'Vé đã hủy hoặc hết hạn sẽ ở đây.',
    };
  }
}

// ==========================================
// 2. TICKET CARD (THẺ HIỂN THỊ TỪNG VÉ)
// ==========================================
class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    String dateStr = '--/--';
    String timeStr = '--:--';

    try {
      if (ticket.showTime.isNotEmpty) {
        final parsedDate = DateTime.parse(ticket.showTime).toLocal();
        dateStr = DateFormat('dd/MM/yyyy').format(parsedDate);
        timeStr = DateFormat('HH:mm').format(parsedDate);
      }
    } catch (_) {}

    final formattedPrice = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(ticket.totalPrice);

    // Gọi hàm ImageHelper của bồ để lấy URL hoặc đường dẫn local
    final imageUrl = ImageHelper.getCorrectImageUrl(ticket.moviePosterUrl);
    final isNetworkImage = imageUrl.startsWith('http');

    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CƠ CHẾ XỬ LÝ ẢNH POSTER
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: isNetworkImage
                    ? Image.network(
                  imageUrl,
                  width: 62,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackImage(),
                )
                    : Image.asset(
                  imageUrl, // Nếu ImageHelper trả về assets/... thì dùng Image.asset
                  width: 62,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackImage(),
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
                      style: AppTypography.subtitle.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ticket.cinemaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: ticket.status,
                backgroundColor: _getStatusColor(ticket.status).withOpacity(0.1),
                foregroundColor: _getStatusColor(ticket.status),
                borderColor: _getStatusColor(ticket.status),
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
              AppBadge(label: ticket.roomName, icon: const Icon(Icons.meeting_room_outlined, size: 14)),
              AppBadge(label: ticket.seatCodes, icon: const Icon(Icons.event_seat, size: 14)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã vé: ${ticket.code}',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ),
              Text(
                formattedPrice,
                style: AppTypography.bodyStrong.copyWith(color: AppColors.brandPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khối ảnh dự phòng (fallback) nếu lỗi load ảnh
  Widget _buildFallbackImage() {
    return Container(
      width: 62,
      height: 85,
      color: AppColors.bgSurface3,
      child: const Icon(Icons.movie, color: AppColors.textMuted),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'BOOKED':
      case 'PAID':
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
      case 'CANCELED':
      case 'EXPIRED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==========================================
// 3. TICKET TABS (NÚT CHỌN TRẠNG THÁI)
// ==========================================
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
            backgroundColor:
            selected ? AppColors.brandPrimary : AppColors.bgSurface2,
            side: BorderSide(
              color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
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