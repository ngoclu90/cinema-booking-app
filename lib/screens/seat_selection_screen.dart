import 'package:flutter/material.dart';
import '../api/services/booking_api.dart';
import '../components/booking/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../utils/app_notifier.dart';

/*
 * Màn hình SeatSelectionScreen:
 * Quản lý trực quan sơ đồ phòng chiếu, cho phép người dùng lựa chọn ghế trống (Normal hoặc VIP).
 * Tích hợp tính năng giữ ghế (hold seats) thông qua BookingApi trước khi chuyển sang bước tiếp theo.
 */
class SeatSelectionScreen extends StatefulWidget {
  final MoviePublicDto movie;
  final Showtime showtime;
  final Cinema cinema;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.cinema,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

/*
 * Trạng thái của SeatSelectionScreen:
 * Thiết lập sơ đồ phòng chiếu (blueprint) tĩnh, quản lý danh sách ghế đã được đặt và ghế đang chọn.
 * Tính toán trực tiếp đơn giá vé theo loại ghế và điều phối API giữ ghế bất đồng bộ.
 */
class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const List<List<String?>> _seatBlueprint = [
    ['A1', 'A2', 'A3', 'A4', null, 'A5', 'A6', 'A7', 'A8'],
    ['B1', 'B2', 'B3', 'B4', null, 'B5', 'B6', 'B7', 'B8'],
    ['C1', 'C2', 'C3', 'C4', null, 'C5', 'C6', 'C7', 'C8'],
    ['D1', 'D2', 'D3', 'D4', null, 'D5', 'D6', 'D7', 'D8'],
    ['E1', 'E2', 'E3', 'E4', null, 'E5', 'E6', 'E7', 'E8'],
    ['F1', 'F2', 'F3', 'F4', null, 'F5', 'F6', 'F7', 'F8'],
  ];

  final BookingApi _bookingApi = const BookingApi();
  final Set<String> _selectedSeats = <String>{};
  final Set<String> _vipSeats = {
    'E5',
    'E6',
    'E7',
    'E8',
    'F5',
    'F6',
    'F7',
    'F8',
  };

  bool _loading = true;
  bool _holding = false;
  Object? _error;
  Set<String> _bookedSeats = <String>{};

  @override
  void initState() {
    super.initState();
    _loadSeatMap();
  }

  Future<void> _loadSeatMap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() {
        _bookedSeats = _buildBookedSeats(widget.showtime.id);
        _selectedSeats.clear();
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

  Set<String> _buildBookedSeats(String showtimeId) {
    return switch (showtimeId) {
      'show-2' => {'A2', 'A3', 'B5', 'C4', 'D6', 'E2', 'E7', 'F4'},
      'show-3' => {'A5', 'B1', 'B2', 'C7', 'D3', 'D4', 'E6', 'F7'},
      'show-4' => {'A1', 'A8', 'B4', 'C2', 'C3', 'D7', 'E5', 'F2', 'F3'},
      _ => {'A4', 'B6', 'C5', 'D2', 'E3', 'F6'},
    };
  }

  bool get _hasAvailableSeat {
    return _seatBlueprint
        .expand((row) => row)
        .whereType<String>()
        .any((seat) => !_bookedSeats.contains(seat));
  }

  List<String> get _selectedSeatLabels {
    final seats = _selectedSeats.toList(growable: false)..sort();
    return seats;
  }

  int get _ticketPrice {
    final normalized = widget.showtime.price
        .toLowerCase()
        .replaceAll('k', '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    return (int.tryParse(normalized) ?? 0) * 1000;
  }

  int get _totalPrice {
    var total = 0;
    for (final seat in _selectedSeats) {
      final isVip = _vipSeats.contains(seat);
      total += isVip ? (_ticketPrice * 1.2).round() : _ticketPrice;
    }
    return total;
  }

  void _toggleSeat(String seat) {
    if (_bookedSeats.contains(seat)) return;
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }

  Future<void> _completeSelection() async {
    if (_selectedSeats.isEmpty || _holding) return;
    setState(() => _holding = true);

    final response = await _bookingApi.holdSeats(
      showtimeId: widget.showtime.id,
      seats: _selectedSeatLabels,
    );

    if (!mounted) return;
    setState(() => _holding = false);

    if (!response.data) {
      AppNotifier.warning(
        context,
        title: 'Chưa giữ được ghế',
        description: 'Hãy chọn ít nhất một ghế để tiếp tục.',
      );
      return;
    }

    AppNotifier.success(
      context,
      title: 'Đã giữ ghế',
      description:
      '${widget.movie.title} · ${_selectedSeatLabels.join(', ')} sẵn sàng thanh toán.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Chọn ghế',
              subtitle: '${widget.showtime.time} · ${widget.showtime.screen}',
              leading: AppHeaderIconButton(
                icon: Icons.arrow_back,
                label: 'Quay lại',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.brandPrimary,
                backgroundColor: AppColors.bgSurface,
                onRefresh: _loadSeatMap,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          144,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _buildContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !_loading && _error == null && _hasAvailableSeat
          ? BookingFooter(
        selectedSeats: _selectedSeatLabels,
        totalPrice: _formatPrice(_totalPrice),
        fallbackPrice: widget.showtime.price,
        onContinue: _holding ? () {} : _completeSelection,
      )
          : null,
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Column(
        key: ValueKey('seat-loading'),
        children: [
          AppSkeletonBox(height: 112),
          SizedBox(height: AppSpacing.md),
          AppSkeletonBox(height: 280),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('seat-error'),
        title: 'Không mở được sơ đồ ghế',
        message: 'Hãy thử lại để cập nhật ghế trống cho suất chiếu này.',
        onRetry: _loadSeatMap,
      );
    }

    if (!_hasAvailableSeat) {
      return AppEmptyState(
        key: const ValueKey('seat-empty'),
        title: 'Suất chiếu đã kín chỗ',
        message: 'Bạn có thể quay lại và chọn suất khác.',
        actionLabel: 'Tải lại',
        onAction: _loadSeatMap,
      );
    }

    return Column(
      key: const ValueKey('seat-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookingSummary(
          movie: widget.movie,
          showtime: widget.showtime,
          cinema: widget.cinema,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _ScreenIndicator(),
        const SizedBox(height: AppSpacing.md),
        const SeatLegend(),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: AppCardPadding.md,
          child: SeatGrid(
            blueprint: _seatBlueprint,
            selectedSeats: _selectedSeats,
            bookedSeats: _bookedSeats,
            vipSeats: _vipSeats,
            onSeatPressed: _toggleSeat,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int amount) {
    if (amount <= 0) return '0k';
    return '${(amount / 1000).round()}k';
  }
}

/*
 * Component _BookingSummary:
 * Thẻ hiển thị tóm tắt thông tin của vé đang đặt bao gồm Tiêu đề phim, Cụm rạp chiếu,
 * Ngày chiếu, Giờ chiếu, Phòng chiếu và Đơn giá gốc.
 */
class _BookingSummary extends StatelessWidget {
  final MoviePublicDto movie;
  final Showtime showtime;
  final Cinema cinema;

  const _BookingSummary({
    required this.movie,
    required this.showtime,
    required this.cinema,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            cinema.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(
                label: showtime.dateLabel,
                icon: const Icon(Icons.event),
              ),
              AppBadge(label: showtime.time, icon: const Icon(Icons.schedule)),
              AppBadge(
                label: showtime.screen,
                icon: const Icon(Icons.meeting_room_outlined),
              ),
              AppBadge(
                label: showtime.price,
                icon: const Icon(Icons.payments_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
 * Component _ScreenIndicator:
 * Thanh định hướng giả lập vị trí màn hình chiếu phim thực tế để người dùng dễ dàng căn chỉnh hướng ngồi trước khi chọn ghế.
 */
class _ScreenIndicator extends StatelessWidget {
  const _ScreenIndicator();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        children: [
          Container(
            height: 4,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'MÀN HÌNH',
            style: AppTypography.captionStrong.copyWith(
              color: AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}