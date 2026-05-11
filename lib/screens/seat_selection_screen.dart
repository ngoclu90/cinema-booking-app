import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/services/booking_api.dart';
import '../components/booking/index.dart';
import '../data/services/showtime_service.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../models/showtime_seat_map.dart';
import '../screens/booking_screen.dart';
import '../utils/app_notifier.dart';
import '../utils/image_helper.dart';

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

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final BookingApi _bookingApi = BookingApi();
  final ShowtimeService _showtimeService = ShowtimeService();
  final Set<String> _selectedSeats = <String>{};

  List<List<String?>> _seatBlueprint = <List<String?>>[];
  Set<String> _vipSeats = <String>{};
  Set<String> _coupleSeats = <String>{};
  Set<String> _bookedSeats = <String>{};
  final Map<String, int> _seatPrices = <String, int>{};
  final Map<String, int> _seatIds = <String, int>{};
  final Map<int, String> _seatCodesById = <int, String>{};
  ShowtimeSeatMap? _seatMap;

  bool _loading = true;
  bool _holding = false;
  Object? _error;

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
      final response = await _showtimeService.getShowtimeSeatMap(
        widget.showtime.id,
      );
      final seatMap = response?.data;
      if (seatMap == null) {
        throw StateError('Seat map is empty');
      }

      final blueprint = <List<String?>>[];
      final vipSeats = <String>{};
      final coupleSeats = <String>{};
      final bookedSeats = <String>{};
      final seatPrices = <String, int>{};
      final seatIds = <String, int>{};
      final seatCodesById = <int, String>{};

      for (final row in seatMap.seatMap) {
        if (row.seats.isEmpty) continue;
        final rowSeats = <String?>[];
        for (final seat in row.seats) {
          final code = seat.code.isNotEmpty
              ? seat.code
              : '${row.rowLabel}${seat.number}';
          rowSeats.add(code);
          if (seat.price > 0) {
            seatPrices[code] = seat.price;
          }
          if (seat.id > 0) {
            seatIds[code] = seat.id;
            seatCodesById[seat.id] = code;
          }

          final seatType = seat.type.toUpperCase();
          if (seatType == 'VIP') {
            vipSeats.add(code);
          }
          if (seatType == 'COUPLE') {
            coupleSeats.add(code);
          }

          if (seat.status.toUpperCase() != 'AVAILABLE') {
            bookedSeats.add(code);
          }
        }
        blueprint.add(rowSeats);
      }

      if (!mounted) return;
      setState(() {
        _seatMap = seatMap;
        _seatBlueprint = blueprint;
        _vipSeats = vipSeats;
        _coupleSeats = coupleSeats;
        _bookedSeats = bookedSeats;
        _seatPrices
          ..clear()
          ..addAll(seatPrices);
        _seatIds
          ..clear()
          ..addAll(seatIds);
        _seatCodesById
          ..clear()
          ..addAll(seatCodesById);
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
      final seatPrice = _seatPrices[seat];
      if (seatPrice != null && seatPrice > 0) {
        total += seatPrice;
        continue;
      }
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
    final showtimeId =
        _seatMap?.showtimeId ?? int.tryParse(widget.showtime.id) ?? 0;
    if (showtimeId == 0) {
      AppNotifier.warning(
        context,
        title: 'Không xác định suất chiếu',
        description: 'Vui lòng thử lại để cập nhật suất chiếu.',
      );
      return;
    }

    final seatIds = _selectedSeats
        .map((seat) => _seatIds[seat])
        .whereType<int>()
        .toList(growable: false);
    if (seatIds.length != _selectedSeats.length) {
      AppNotifier.warning(
        context,
        title: 'Thiếu dữ liệu ghế',
        description: 'Vui lòng tải lại sơ đồ ghế rồi thử lại.',
      );
      return;
    }

    setState(() => _holding = true);
    final response = await _bookingApi.holdSeats(
      showtimeId: showtimeId,
      seatIds: seatIds,
    );

    if (!mounted) return;
    setState(() => _holding = false);

    if (response == null || response.success != true) {
      AppNotifier.warning(
        context,
        title: 'Chưa giữ được ghế',
        description: response?.message.isNotEmpty == true
            ? response!.message
            : 'Vui lòng thử lại để giữ ghế.',
      );
      return;
    }

    if (response.failedSeatIds.isNotEmpty) {
      final failed = response.failedSeatIds
          .map((id) => _seatCodesById[id] ?? id.toString())
          .join(', ');
      AppNotifier.warning(
        context,
        title: 'Một số ghế chưa giữ được',
        description: 'Ghế lỗi: $failed. Vui lòng chọn lại.',
      );
      return;
    }

    AppNotifier.success(
      context,
      title: 'Đã giữ ghế',
      description:
          '${widget.movie.title} · ${_selectedSeatLabels.join(', ')} sẵn sàng chọn combo.',
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          initialSelectedSeats: _selectedSeatLabels,
          initialSeatIds: seatIds,
          initialSeatTotal: _totalPrice,
          initialStep: 1,
          skipSeatStep: true,
          holdExpiresAt: response.expiresAt,
          holdToken: response.holdToken,
        ),
      ),
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
                  physics: const AlwaysScrollableScrollPhysics(),
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
          seatMap: _seatMap,
          selectedSeats: _selectedSeatLabels,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _ScreenIndicator(),
        const SizedBox(height: AppSpacing.md),
        const SeatLegend(),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: AppCardPadding
              .sm, // Sửa thành AppCardPadding.sm của hệ thống để hết lỗi đỏ
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SeatGrid(
              blueprint: _seatBlueprint,
              selectedSeats: _selectedSeats,
              bookedSeats: _bookedSeats,
              vipSeats: _vipSeats,
              coupleSeats: _coupleSeats,
              onSeatPressed: _toggleSeat,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int amount) {
    if (amount <= 0) return '0đ';
    return '${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ';
  }
}

class _BookingSummary extends StatelessWidget {
  final MoviePublicDto movie;
  final Showtime showtime;
  final Cinema cinema;
  final ShowtimeSeatMap? seatMap;
  final List<String> selectedSeats;

  const _BookingSummary({
    required this.movie,
    required this.showtime,
    required this.cinema,
    this.seatMap,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = (seatMap?.movieTitle.isNotEmpty ?? false)
        ? seatMap!.movieTitle
        : movie.title;
    final resolvedCinema = (seatMap?.cinemaName.isNotEmpty ?? false)
        ? seatMap!.cinemaName
        : cinema.name;
    final resolvedRoom = (seatMap?.roomName.isNotEmpty ?? false)
        ? seatMap!.roomName
        : showtime.screen;
    final resolvedGenre = (seatMap?.genre.isNotEmpty ?? false)
        ? seatMap!.genre
        : (movie.genre ?? '');

    final durationMinutes = seatMap?.duration ?? movie.durationMinutes;
    final durationLabel = durationMinutes > 0 ? '$durationMinutes phút' : '—';

    final startTime = seatMap?.startTime;
    final resolvedDateLabel = startTime != null
        ? DateFormat('dd/MM/yyyy').format(startTime.toLocal())
        : showtime.dateLabel;
    final resolvedTimeLabel = startTime != null
        ? DateFormat('HH:mm').format(startTime.toLocal())
        : showtime.time;
    final seatLabel = selectedSeats.isNotEmpty
        ? selectedSeats.join(', ')
        : 'Chưa chọn';

    final posterUrl = ImageHelper.getCorrectImageUrl(
      (seatMap?.moviePosterUrl.isNotEmpty ?? false)
          ? seatMap!.moviePosterUrl
          : movie.posterUrl,
    );
    final isAssetPoster = posterUrl.startsWith('assets/');

    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: posterUrl.isNotEmpty
                        ? (isAssetPoster
                              ? Image.asset(posterUrl, fit: BoxFit.cover)
                              : Image.network(
                                  posterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.bgSurface2,
                                    child: const Icon(
                                      Icons.movie,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ))
                        : Container(
                            color: AppColors.bgSurface2,
                            child: const Icon(
                              Icons.movie,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      resolvedGenre.isNotEmpty ? resolvedGenre : '—',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      resolvedTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.borderDefault),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Thể loại',
            value: resolvedGenre.isNotEmpty ? resolvedGenre : '—',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Thời lượng',
            value: durationLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Rạp chiếu',
            value: resolvedCinema,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Ngày chiếu',
            value: resolvedDateLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Giờ chiếu',
            value: resolvedTimeLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.meeting_room_outlined,
            label: 'Phòng chiếu',
            value: resolvedRoom,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.event_seat_outlined,
            label: 'Ghế',
            value: seatLabel,
            highlight: selectedSeats.isNotEmpty,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          textAlign: TextAlign.right,
          style: AppTypography.bodyStrong.copyWith(
            color: highlight ? AppColors.brandPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ScreenIndicator extends StatelessWidget {
  const _ScreenIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'MÀN HÌNH CHIẾU',
            style: AppTypography.captionStrong.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
