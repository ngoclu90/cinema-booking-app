import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/services/booking_api.dart';
import '../data/services/combo_service.dart';
import '../data/services/voucher_service.dart';
import '../models/combo.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';
import '../utils/image_helper.dart';
import 'payment_webview_screen.dart';

/*
 * Màn hình BookingScreen:
 * Quản lý quy trình đặt vé xem phim qua 3 bước.
 * Hiện tại chỉ nhận thông tin Movie và Showtime từ API qua Constructor.
 * Các dữ liệu phụ trợ chưa có API sẽ tạm thời được tự quản lý nội bộ bên trong State để giao diện hoạt động độc lập.
 */
class BookingScreen extends StatefulWidget {
  final MoviePublicDto movie;
  final Showtime showtime;
  final int userId;
  final List<String> initialSelectedSeats;
  final List<int> initialSeatIds;
  final int initialSeatTotal;
  final int initialStep;
  final bool skipSeatStep;
  final DateTime? holdExpiresAt;
  final String? holdToken;

  const BookingScreen({
    super.key,
    required this.movie,
    required this.showtime,
    this.userId = 0,
    this.initialSelectedSeats = const <String>[],
    this.initialSeatIds = const <int>[],
    this.initialSeatTotal = 0,
    this.initialStep = 0,
    this.skipSeatStep = false,
    this.holdExpiresAt,
    this.holdToken,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

/*
 * Trạng thái của BookingScreen:
 * Chứa các hằng số dữ liệu cục bộ phục vụ cho việc giả lập combo bắp nước, ghế đã khóa và thanh toán.
 * Xử lý logic đếm ngược thời gian giữ ghế và tính toán doanh thu đơn hàng.
 */
class _BookingScreenState extends State<BookingScreen> {
  static const List<String> _stepTitles = [
    'Chọn ghế',
    'Combo & mã giảm giá',
    'Phương thức thanh toán',
  ];

  static const String _cinemaName = 'Beta Two Sài Gòn Center';

  final ComboService _comboService = ComboService();
  final BookingApi _bookingApi = BookingApi();
  final VoucherService _voucherService = VoucherService();
  List<Combo> _combos = const <Combo>[];
  bool _comboLoading = true;
  Object? _comboError;
  bool _checkingVoucher = false;

  final List<String> _paymentMethods = const ['MoMo', 'VNPay'];

  final Set<String> _lockedSeats = const {
    'A3',
    'A10',
    'B4',
    'B9',
    'C5',
    'C8',
    'D2',
    'D11',
    'E2',
  };

  final TextEditingController _promoController = TextEditingController();
  final Set<String> _selectedSeats = <String>{};
  final List<int> _selectedSeatIds = <int>[];
  final Map<int, int> _comboQty = <int, int>{};
  int? _seatTotalOverride;
  bool _calculating = false;
  bool _creatingBooking = false;
  bool _releasingSeats = false;
  int? _voucherDiscountAmount;
  int? _voucherFinalPrice;

  int _currentStep = 0;
  int _holdSeconds = 600;
  String? _promoApplied;
  String? _selectedPaymentMethod;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedSeats.isNotEmpty) {
      _selectedSeats.addAll(widget.initialSelectedSeats);
    }

    if (widget.initialSeatIds.isNotEmpty) {
      _selectedSeatIds.addAll(widget.initialSeatIds);
    }

    if (widget.initialSeatTotal > 0) {
      _seatTotalOverride = widget.initialSeatTotal;
    }

    _currentStep = widget.skipSeatStep && widget.initialStep == 0
        ? 1
        : widget.initialStep;
    if (widget.holdExpiresAt != null) {
      final remaining = widget.holdExpiresAt!
          .difference(DateTime.now())
          .inSeconds;
      _holdSeconds = remaining > 0 ? remaining : 0;
    }
    _loadCombos();
    _startHoldCountdown();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  int get _ticketUnitPrice => _parsePrice(widget.showtime.price);

  int get _seatTotal =>
      _seatTotalOverride ?? (_selectedSeats.length * _ticketUnitPrice);

  int get _comboTotal {
    var total = 0;
    for (final combo in _combos) {
      total += combo.price * (_comboQty[combo.id] ?? 0);
    }
    return total;
  }

  Future<void> _loadCombos() async {
    setState(() {
      _comboLoading = true;
      _comboError = null;
    });

    try {
      final response = await _comboService.getCombos();
      if (!mounted) return;
      setState(() {
        _combos = response?.data ?? const <Combo>[];
        _comboLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _comboError = error;
        _comboLoading = false;
      });
    }
  }

  int get _subtotal => _seatTotal + _comboTotal;

  int get _discountAmount {
    if (_voucherDiscountAmount == null) return 0;
    final amount = _voucherDiscountAmount!;
    if (amount <= 0) return 0;
    return amount > _subtotal ? _subtotal : amount;
  }

  int get _total {
    if (_voucherFinalPrice != null) {
      final total = _voucherFinalPrice!;
      return total < 0 ? 0 : total;
    }
    return _subtotal - _discountAmount;
  }

  String get _holdTimeLabel {
    final minutes = (_holdSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_holdSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) _buildCompactMovieInfo(context),
                    if (_currentStep != 0) _buildMovieSummary(context),
                    const SizedBox(height: AppSpacing.lg),
                    if (_currentStep == 0) _buildSeatStep(context),
                    if (_currentStep == 1) _buildComboAndPromoStep(context),
                    if (_currentStep == 2) _buildPaymentStep(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isSeatStep = _currentStep == 0;
    final isPaymentStep = _currentStep == 2;
    final title = isSeatStep ? 'Chọn Ghế' : _stepTitles[_currentStep];
    final showHoldTimer = widget.holdExpiresAt != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isPaymentStep ? null : _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Quay lại',
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (showHoldTimer)
            Row(
              children: [
                if (!isSeatStep)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      'Bước ${_currentStep + 1}/3',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.66),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlphaPercent(0.14),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlphaPercent(0.34),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _holdTimeLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                'Bước ${_currentStep + 1}/3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlphaPercent(0.66),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMovieInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppTheme.surfaceLayer(context, level: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              width: 58,
              height: 82,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.movie.accentColor.withAlphaPercent(0.92),
                    Color.lerp(widget.movie.accentColor, Colors.black, 0.46)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.movie.title.isEmpty ? '?' : widget.movie.title[0],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _cinemaName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.showtime.dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.62),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.showtime.time} - ${widget.showtime.screen}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.62),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSummary(BuildContext context) {
    final seatLabel = _selectedSeats.isEmpty
        ? 'Chưa chọn'
        : (_selectedSeats.toList()..sort()).join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppTheme.surfaceLayer(context, level: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${widget.showtime.dateLabel} · ${widget.showtime.time} · ${widget.showtime.screen}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ghế: $seatLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tiền vé: ${_formatCurrency(_seatTotal)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSeatStep(BuildContext context) {
    const rows = ['A', 'B', 'C', 'D', 'E'];
    const normalCols = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    const coupleCols = [1, 2, 3, 4, 5, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.16),
                Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.06),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Màn hình',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLayer(context, level: 1),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  color: AppTheme.surfaceLayer(context, level: 2),
                ),
                child: Column(
                  children: rows
                      .map(
                        (row) => SizedBox(
                          height: row == 'E' ? 44 : 36,
                          child: Center(
                            child: Text(
                              row,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlphaPercent(0.74),
                                  ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rows
                        .map((row) {
                          final cols = row == 'E' ? coupleCols : normalCols;
                          final seatType = _seatTypeByRow(row);
                          return SizedBox(
                            height: row == 'E' ? 44 : 36,
                            child: Row(
                              children: cols
                                  .map((col) {
                                    final seatId = '$row$col';
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 6,
                                        bottom: 6,
                                      ),
                                      child: _buildSeatCell(
                                        context,
                                        seatId: seatId,
                                        seatType: seatType,
                                        isCoupleSeat: row == 'E',
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _legendItem(
              context,
              'Ghế thường',
              _seatTypeColor(context, _SeatType.normal),
            ),
            _legendItem(
              context,
              'Ghế VIP',
              _seatTypeColor(context, _SeatType.vip),
            ),
            _legendItem(
              context,
              'Ghế đôi',
              _seatTypeColor(context, _SeatType.couple),
            ),
            _legendItem(
              context,
              'Đang chọn',
              Theme.of(context).colorScheme.primary,
            ),
            _legendItem(
              context,
              'Đã đặt',
              Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatCell(
    BuildContext context, {
    required String seatId,
    required _SeatType seatType,
    required bool isCoupleSeat,
  }) {
    final isLocked = _lockedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final baseColor = _seatTypeColor(context, seatType);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isLocked
            ? null
            : () {
                setState(() {
                  _seatTotalOverride = null;
                  _selectedSeatIds.clear();
                  if (isSelected) {
                    _selectedSeats.remove(seatId);
                  } else {
                    _selectedSeats.add(seatId);
                  }
                });
              },
        child: AnimatedContainer(
          duration: AppDurations.short,
          width: isCoupleSeat ? 56 : 26,
          height: isCoupleSeat ? 36 : 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isLocked
                ? Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.16)
                : isSelected
                ? Theme.of(context).colorScheme.primary
                : baseColor,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.18),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlphaPercent(0.26),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            seatId,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  _SeatType _seatTypeByRow(String row) {
    if (row == 'A' || row == 'B') return _SeatType.normal;
    if (row == 'C' || row == 'D') return _SeatType.vip;
    return _SeatType.couple;
  }

  Color _seatTypeColor(BuildContext context, _SeatType seatType) {
    switch (seatType) {
      case _SeatType.normal:
        return Theme.of(context).colorScheme.secondary.withAlphaPercent(0.12);
      case _SeatType.vip:
        return const Color(
          0xFFD79A34,
        ).withAlphaPercent(context.isDarkMode ? 0.26 : 0.18);
      case _SeatType.couple:
        return const Color(
          0xFFB14ED8,
        ).withAlphaPercent(context.isDarkMode ? 0.28 : 0.16);
    }
  }

  Widget _legendItem(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: AppTheme.surfaceLayer(context, level: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildComboAndPromoStep(BuildContext context) {
    if (_comboLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước 2: Chọn combo và mã giảm giá',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    }

    if (_comboError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước 2: Chọn combo và mã giảm giá',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Không tải được combo. Vui lòng thử lại.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _loadCombos,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 2: Chọn combo và mã giảm giá',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_combos.isEmpty)
          Text(
            'Chưa có combo khả dụng.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ..._combos.map((combo) {
            final qty = _comboQty[combo.id] ?? 0;
            final imageUrl = ImageHelper.getCorrectImageUrl(combo.imageUrl);
            final detail = combo.description.isNotEmpty
                ? combo.description
                : combo.itemList
                      .map((item) => '${item.quantity} ${item.productName}')
                      .join(' + ');
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                color: AppTheme.surfaceLayer(context, level: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: imageUrl.startsWith('assets/')
                          ? Image.asset(imageUrl, fit: BoxFit.cover)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                child: const Icon(Icons.local_movies_outlined),
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
                          combo.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlphaPercent(0.72),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCurrency(combo.price),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: qty == 0
                            ? null
                            : () {
                                setState(() {
                                  _comboQty[combo.id] = qty - 1;
                                });
                              },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: combo.stock > 0
                            ? () {
                                setState(() {
                                  _comboQty[combo.id] = qty + 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _promoController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Nhập mã giảm giá',
            suffixIcon: TextButton(
              onPressed: _checkingVoucher ? null : _applyPromo,
              child: _checkingVoucher
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Áp dụng'),
            ),
          ),
        ),
        if (_promoApplied != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withAlphaPercent(0.12),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              'Đã áp dụng mã $_promoApplied - giảm ${_formatCurrency(_discountAmount)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 3: Chọn phương thức thanh toán',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withAlphaPercent(0.12)
                        : AppTheme.surfaceLayer(context, level: 1),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlphaPercent(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          method,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlphaPercent(0.45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final selectedSeats = _selectedSeats.toList()..sort();
    final seatLabel = selectedSeats.isEmpty
        ? 'Chưa chọn'
        : selectedSeats.join(', ');
    final isPrimaryDisabled =
        _calculating || (_currentStep == 2 && _creatingBooking);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlphaPercent(
              context.isDarkMode ? 0.88 : 0.94,
            ),
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlphaPercent(0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaPercent(
                  context.isDarkMode ? 0.26 : 0.1,
                ),
                blurRadius: 22,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentStep == 0)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ghế: $seatLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tổng cộng: ${_formatCurrency(_total)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: _showPriceDetail,
                      icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      tooltip: 'Xem chi tiết',
                    ),
                  ],
                ),
              if (_currentStep != 0) ...[
                _priceLine(context, 'Tiền vé', _formatCurrency(_seatTotal)),
                _priceLine(context, 'Combo', _formatCurrency(_comboTotal)),
                _priceLine(
                  context,
                  'Giảm giá',
                  '- ${_formatCurrency(_discountAmount)}',
                ),
                const SizedBox(height: 6),
                _priceLine(
                  context,
                  'Tổng thanh toán',
                  _formatCurrency(_total),
                  isTotal: true,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (_currentStep > 0 && _currentStep != 2)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleBack,
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentStep > 0 && _currentStep != 2)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isPrimaryDisabled ? null : _onPrimaryAction,
                      icon: Icon(
                        _currentStep == 2
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _currentStep == 2 ? 'Thanh toán' : 'Tiếp tục',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceLine(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            value,
            style: textStyle?.copyWith(
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppNotifier.warning(
        context,
        title: 'Thiếu mã giảm giá',
        description: 'Bạn hãy nhập mã rồi thử lại.',
      );
      return;
    }

    if (_checkingVoucher) return;

    setState(() {
      _checkingVoucher = true;
      _voucherDiscountAmount = null;
      _voucherFinalPrice = null;
      _promoApplied = null;
    });

    try {
      final response = await _voucherService.checkVoucher(
        code: code,
        price: _subtotal,
      );

      if (!mounted) return;

      if (response == null) {
        setState(() => _checkingVoucher = false);
        AppNotifier.warning(
          context,
          title: 'Mã chưa hợp lệ',
          description: 'Mã giảm giá không tồn tại hoặc đã hết hạn.',
        );
        return;
      }

      final voucher = response.data;
      final clampedDiscount = voucher.discountAmount
          .clamp(0, _subtotal)
          .toInt();
      final resolvedFinalPrice = voucher.finalPrice
          .clamp(0, _subtotal)
          .toInt();

      setState(() {
        _checkingVoucher = false;
        _promoApplied =
            voucher.voucherCode.isNotEmpty ? voucher.voucherCode : code;
        _voucherDiscountAmount = clampedDiscount;
        _voucherFinalPrice = resolvedFinalPrice;
      });

      AppNotifier.success(
        context,
        title: response.message.isNotEmpty
            ? response.message
            : 'Áp dụng mã thành công',
        description: 'Bạn đã tiết kiệm ${_formatCurrency(_discountAmount)}.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingVoucher = false);
      AppNotifier.warning(
        context,
        title: 'Không thể áp dụng mã',
        description: 'Vui lòng thử lại sau.',
      );
    }
  }

  void _onPrimaryAction() {
    if (_currentStep == 0) {
      if (_selectedSeats.isEmpty) {
        AppNotifier.warning(
          context,
          title: 'Chưa chọn ghế',
          description: 'Bạn cần chọn ít nhất 1 ghế để tiếp tục.',
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_currentStep == 1) {
      _calculateAndContinue();
      return;
    }

    if (_selectedPaymentMethod == null) {
      AppNotifier.warning(
        context,
        title: 'Chưa chọn thanh toán',
        description: 'Vui lòng chọn phương thức thanh toán.',
      );
      return;
    }

    _submitBooking();
  }

  String _resolvePaymentMethodCode(String label) {
    switch (label) {
      case 'MoMo':
        return 'MOMO';
      case 'VNPay':
        return 'VNPAY';
      default:
        return label.toUpperCase();
    }
  }

  String _resolveBankCode(String paymentMethod) {
    if (paymentMethod == 'MOMO') {
      return 'ATM';
    }
    return '';
  }

  List<Map<String, dynamic>> _buildBookingCombosPayload() {
    final combosPayload = <Map<String, dynamic>>[];
    for (final combo in _combos) {
      final qty = _comboQty[combo.id] ?? 0;
      if (qty <= 0) continue;
      combosPayload.add({
        'id': combo.id,
        'comboId': combo.id,
        'quantity': qty,
      });
    }
    return combosPayload;
  }

  Future<void> _submitBooking() async {
    if (_creatingBooking) return;

    if (_selectedSeatIds.isEmpty) {
      AppNotifier.warning(
        context,
        title: 'Thiếu thông tin ghế',
        description: 'Vui lòng quay lại chọn ghế để tiếp tục.',
      );
      return;
    }

    final showtimeId = int.tryParse(widget.showtime.id) ?? 0;
    if (showtimeId == 0) {
      AppNotifier.warning(
        context,
        title: 'Không xác định suất chiếu',
        description: 'Vui lòng quay lại và chọn suất chiếu.',
      );
      return;
    }

    final resolvedUserId = await _resolveUserId();
    if (resolvedUserId == 0) {
      AppNotifier.warning(
        context,
        title: 'Thiếu thông tin người dùng',
        description: 'Vui lòng đăng nhập lại để tiếp tục.',
      );
      return;
    }

    final paymentMethod = _resolvePaymentMethodCode(_selectedPaymentMethod!);
    final bankCode = _resolveBankCode(paymentMethod);
    final voucherCode = _promoApplied ?? _promoController.text.trim();
    final combosPayload = _buildBookingCombosPayload();
    final productsPayload = <Map<String, dynamic>>[];

    setState(() => _creatingBooking = true);
    final booking = await _bookingApi.createBooking(
      userId: resolvedUserId,
      showtimeId: showtimeId,
      seatIds: _selectedSeatIds,
      combos: combosPayload,
      products: productsPayload,
      voucherCode: voucherCode,
      paymentMethod: paymentMethod,
      bankCode: bankCode,
    );

    if (!mounted) return;
    setState(() => _creatingBooking = false);

    if (booking == null) {
      AppNotifier.warning(
        context,
        title: 'Chưa tạo được đơn',
        description: 'Vui lòng thử lại để thanh toán.',
      );
      return;
    }

    if (booking.paymentUrl.isNotEmpty) {
      AppNotifier.success(
        context,
        title: 'Tạo đơn thành công',
        description: 'Đang mở trang thanh toán MoMo/VNPay.',
      );
      _openPaymentWebView(booking.paymentUrl);
      return;
    }

    final seats = _selectedSeats.toList()..sort();
    AppNotifier.success(
      context,
      title: 'Thanh toán thành công',
      description:
          'Đặt vé thành công cho ${widget.movie.title} (${seats.join(', ')}) với tổng ${_formatCurrency(_total)}.',
    );
    Navigator.of(context).pop();
  }

  void _openPaymentWebView(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentWebViewScreen(paymentUrl: url)),
    );
  }

  Future<int> _resolveUserId() async {
    if (widget.userId > 0) return widget.userId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> _calculateAndContinue() async {
    if (_calculating) return;

    if (_selectedSeatIds.isEmpty) {
      AppNotifier.warning(
        context,
        title: 'Thiếu thông tin ghế',
        description: 'Vui lòng quay lại chọn ghế để tiếp tục.',
      );
      return;
    }

    final showtimeId = int.tryParse(widget.showtime.id) ?? 0;
    if (showtimeId == 0) {
      AppNotifier.warning(
        context,
        title: 'Không xác định suất chiếu',
        description: 'Vui lòng quay lại và chọn suất chiếu.',
      );
      return;
    }

    final combosPayload = _buildBookingCombosPayload();

    final voucherCode = _promoApplied ?? _promoController.text.trim();

    setState(() => _calculating = true);
    final success = await _bookingApi.calculateBooking(
      showtimeId: showtimeId,
      seatIds: _selectedSeatIds,
      combos: combosPayload,
      voucherCode: voucherCode,
    );

    if (!mounted) return;
    setState(() => _calculating = false);

    if (!success) {
      AppNotifier.warning(
        context,
        title: 'Chưa tính được đơn hàng',
        description: 'Vui lòng thử lại để tiếp tục.',
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _showPriceDetail() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.hero),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _priceLine(context, 'Tiền vé', _formatCurrency(_seatTotal)),
              _priceLine(context, 'Combo', _formatCurrency(_comboTotal)),
              _priceLine(
                context,
                'Giảm giá',
                '- ${_formatCurrency(_discountAmount)}',
              ),
              const SizedBox(height: 8),
              _priceLine(
                context,
                'Tổng cộng',
                _formatCurrency(_total),
                isTotal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBack() async {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (_currentStep == 2) {
      return;
    }
    if (_currentStep == 1) {
      final confirmed = await _confirmReleaseSeats();
      if (!confirmed) return;

      final released = await _releaseSeatsIfNeeded();
      if (!released) return;

      if (widget.skipSeatStep) {
        Navigator.of(context).pop();
        return;
      }

      if (!mounted) return;
      setState(() {
        _currentStep -= 1;
      });
      return;
    }
  }

  Future<bool> _confirmReleaseSeats() async {
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xác nhận quay lại'),
            content: const Text(
              'Nếu quay trở lại ghế của bạn sẽ không được giữ, bạn có chắc muốn thoát khỏi quy trình đặt vé này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _releaseSeatsIfNeeded() async {
    if (_releasingSeats) return false;
    final holdToken = widget.holdToken;
    if (holdToken == null || holdToken.trim().isEmpty) return true;

    final showtimeId = int.tryParse(widget.showtime.id) ?? 0;

    setState(() => _releasingSeats = true);
    try {
      final success = await _bookingApi.releaseSeats(
        holdToken: holdToken,
        showtimeId: showtimeId,
        seatIds: _selectedSeatIds,
      );

      if (!mounted) return false;
      setState(() => _releasingSeats = false);

      if (!success) {
        AppNotifier.warning(
          context,
          title: 'Chưa trả được ghế',
          description: 'Vui lòng thử lại để tiếp tục.',
        );
        return false;
      }

      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() => _releasingSeats = false);
      AppNotifier.warning(
        context,
        title: 'Không thể trả ghế',
        description: 'Vui lòng thử lại sau.',
      );
      return false;
    }
  }

  void _startHoldCountdown() {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_holdSeconds <= 0) {
        timer.cancel();
        AppNotifier.warning(
          context,
          title: 'Hết thời gian giữ ghế',
          description: 'Vui lòng chọn lại ghế để tiếp tục đặt vé.',
        );
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      setState(() {
        _holdSeconds -= 1;
      });
    });
  }

  int _parsePrice(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  String _formatCurrency(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}

/*
 * Bộ Enum phân loại ghế:
 * Xác định đặc điểm của 3 loại ghế chính trong rạp chiếu: thường (normal), vip, và đôi (couple).
 */
enum _SeatType { normal, vip, couple }
