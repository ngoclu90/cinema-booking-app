import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/showtime.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';

class BookingScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const BookingScreen({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const List<String> _stepTitles = [
    'Chọn ghế',
    'Combo & mã giảm giá',
    'Phương thức thanh toán',
  ];
  static const String _cinemaName = 'Beta Two Sài Gòn Center';

  final List<_ComboOption> _combos = const [
    _ComboOption(name: 'Combo Couple', detail: '1 bắp + 2 nước', price: 99000),
    _ComboOption(name: 'Combo Family', detail: '2 bắp + 4 nước', price: 189000),
    _ComboOption(name: 'Combo Snack', detail: 'Nachos + 1 nước', price: 79000),
  ];

  final List<String> _paymentMethods = const [
    'Ví MoMo',
    'ZaloPay',
    'Thẻ Visa/MasterCard',
    'Apple Pay',
    'Thanh toán tại quầy',
  ];

  final TextEditingController _promoController = TextEditingController();
  final Set<String> _selectedSeats = <String>{};
  final Map<String, int> _comboQty = <String, int>{};
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

  int _currentStep = 0;
  int _holdSeconds = 600;
  int _percentDiscount = 0;
  int _fixedDiscount = 0;
  String? _promoApplied;
  String? _selectedPaymentMethod;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _startHoldCountdown();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  int get _ticketUnitPrice => _parsePrice(widget.showtime.price);

  int get _seatTotal => _selectedSeats.length * _ticketUnitPrice;

  int get _comboTotal {
    var total = 0;
    for (final combo in _combos) {
      total += combo.price * (_comboQty[combo.name] ?? 0);
    }
    return total;
  }

  int get _subtotal => _seatTotal + _comboTotal;

  int get _discountAmount {
    final percent = ((_subtotal * _percentDiscount) / 100).round();
    final amount = percent + _fixedDiscount;
    if (amount <= 0) return 0;
    return amount > _subtotal ? _subtotal : amount;
  }

  int get _total => _subtotal - _discountAmount;

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
    final title = isSeatStep ? 'Chọn Ghế' : _stepTitles[_currentStep];
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
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Quay lại',
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isSeatStep)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                color: Theme.of(context).colorScheme.primary.withAlphaPercent(0.14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlphaPercent(0.34),
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
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                'Bước ${_currentStep + 1}/3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.66),
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
                    widget.movie.accent.withAlphaPercent(0.92),
                    Color.lerp(widget.movie.accent, Colors.black, 0.46)!,
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
                    color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.showtime.dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.62),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.showtime.time} - ${widget.showtime.screen}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.62),
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
          Text(widget.movie.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${widget.showtime.dateLabel} · ${widget.showtime.time} · ${widget.showtime.screen}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Giá vé: ${_formatCurrency(_ticketUnitPrice)} / ghế',
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 0.6,
            ),
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
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                    children: rows.map((row) {
                      final cols = row == 'E' ? coupleCols : normalCols;
                      final seatType = _seatTypeByRow(row);
                      return SizedBox(
                        height: row == 'E' ? 44 : 36,
                        child: Row(
                          children: cols.map((col) {
                            final seatId = '$row$col';
                            return Padding(
                              padding: const EdgeInsets.only(right: 6, bottom: 6),
                              child: _buildSeatCell(
                                context,
                                seatId: seatId,
                                seatType: seatType,
                                isCoupleSeat: row == 'E',
                              ),
                            );
                          }).toList(growable: false),
                        ),
                      );
                    }).toList(growable: false),
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
            _legendItem(context, 'Ghế thường', _seatTypeColor(context, _SeatType.normal)),
            _legendItem(context, 'Ghế VIP', _seatTypeColor(context, _SeatType.vip)),
            _legendItem(context, 'Ghế đôi', _seatTypeColor(context, _SeatType.couple)),
            _legendItem(context, 'Đang chọn', Theme.of(context).colorScheme.primary),
            _legendItem(context, 'Đã đặt', Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.18)),
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
                  : Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.18),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlphaPercent(0.26),
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
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
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
        return const Color(0xFFD79A34).withAlphaPercent(context.isDarkMode ? 0.26 : 0.18);
      case _SeatType.couple:
        return const Color(0xFFB14ED8).withAlphaPercent(context.isDarkMode ? 0.28 : 0.16);
    }
  }

  Widget _legendItem(
    BuildContext context,
    String label,
    Color color,
  ) {
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboAndPromoStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 2: Chọn combo và mã giảm giá',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._combos.map(
          (combo) {
            final qty = _comboQty[combo.name] ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                color: AppTheme.surfaceLayer(context, level: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(combo.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          combo.detail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlphaPercent(0.72),
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
                                  _comboQty[combo.name] = qty - 1;
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
                        onPressed: () {
                          setState(() {
                            _comboQty[combo.name] = qty + 1;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _promoController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Nhập mã giảm giá (VD: CINEMA10)',
            suffixIcon: TextButton(
              onPressed: _applyPromo,
              child: const Text('Áp dụng'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Mã dùng thử: CINEMA10 (10%), WEEKEND20 (20%), SNACK30K (30.000đ)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.62),
          ),
        ),
        if (_promoApplied != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlphaPercent(0.12),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              'Đã áp dụng mã $_promoApplied - giảm ${_formatCurrency(_discountAmount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
        ..._paymentMethods.map(
          (method) {
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
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlphaPercent(0.12)
                          : AppTheme.surfaceLayer(context, level: 1),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlphaPercent(0.12),
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
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlphaPercent(0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final selectedSeats = _selectedSeats.toList()..sort();
    final seatLabel = selectedSeats.isEmpty ? 'Chưa chọn' : selectedSeats.join(', ');
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
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withAlphaPercent(context.isDarkMode ? 0.88 : 0.94),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withAlphaPercent(0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaPercent(context.isDarkMode ? 0.26 : 0.1),
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
                _priceLine(context, 'Giảm giá', '- ${_formatCurrency(_discountAmount)}'),
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
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep -= 1;
                          });
                        },
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onPrimaryAction,
                      icon: Icon(
                        _currentStep == 2
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(_currentStep == 2 ? 'Thanh toán' : 'Tiếp tục'),
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

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppNotifier.warning(
        context,
        title: 'Thiếu mã giảm giá',
        description: 'Bạn hãy nhập mã rồi thử lại.',
      );
      return;
    }

    setState(() {
      _percentDiscount = 0;
      _fixedDiscount = 0;
      _promoApplied = null;

      if (code == 'CINEMA10') {
        _percentDiscount = 10;
        _promoApplied = code;
      } else if (code == 'WEEKEND20') {
        _percentDiscount = 20;
        _promoApplied = code;
      } else if (code == 'SNACK30K') {
        _fixedDiscount = 30000;
        _promoApplied = code;
      }
    });

    if (_promoApplied == null) {
      AppNotifier.warning(
        context,
        title: 'Mã chưa hợp lệ',
        description: 'Mã giảm giá không tồn tại hoặc đã hết hạn.',
      );
      return;
    }

    AppNotifier.success(
      context,
      title: 'Áp dụng mã thành công',
      description: 'Bạn đã tiết kiệm ${_formatCurrency(_discountAmount)}.',
    );
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
      setState(() {
        _currentStep = 2;
      });
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

    final seats = _selectedSeats.toList()..sort();
    AppNotifier.success(
      context,
      title: 'Thanh toán thành công',
      description:
          'Đặt vé thành công cho ${widget.movie.title} (${seats.join(', ')}) với tổng ${_formatCurrency(_total)}.',
    );
    Navigator.of(context).pop();
  }

  void _showPriceDetail() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
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
              _priceLine(context, 'Giảm giá', '- ${_formatCurrency(_discountAmount)}'),
              const SizedBox(height: 8),
              _priceLine(context, 'Tổng cộng', _formatCurrency(_total), isTotal: true),
            ],
          ),
        );
      },
    );
  }

  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _currentStep -= 1;
    });
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
        setState(() {
          _selectedSeats.clear();
        });
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

class _ComboOption {
  final String name;
  final String detail;
  final int price;

  const _ComboOption({
    required this.name,
    required this.detail,
    required this.price,
  });
}

enum _SeatType { normal, vip, couple }