import 'package:flutter/material.dart';

import '../api/services/voucher_api.dart';
import '../components/ui/index.dart';
import '../components/voucher/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/news_item.dart';
import '../models/voucher.dart';
import '../utils/app_notifier.dart';

enum _VoucherFilter { all, voucher, news }

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with AutomaticKeepAliveClientMixin<VoucherScreen> {
  final VoucherApi _voucherApi = const VoucherApi();

  bool _loading = true;
  Object? _error;
  _VoucherFilter _filter = _VoucherFilter.all;
  List<Voucher> _vouchers = const <Voucher>[];
  List<NewsItem> _news = const <NewsItem>[];

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
      final responses = await Future.wait([
        _voucherApi.getVouchers(),
        _voucherApi.getNews(),
      ]);
      if (!mounted) return;
      setState(() {
        _vouchers = responses[0].data as List<Voucher>;
        _news = responses[1].data as List<NewsItem>;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScreenContainer(
      title: 'Voucher',
      subtitle: 'Ưu đãi và tin nóng tại rạp',
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
        key: ValueKey('voucher-loading'),
        children: [
          AppSkeletonBox(height: 44),
          SizedBox(height: AppSpacing.md),
          AppSkeletonList(itemCount: 5),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('voucher-error'),
        title: 'Không tải được voucher',
        message: 'Hãy thử lại để cập nhật ưu đãi và tin hot.',
        onRetry: _load,
      );
    }

    if (_vouchers.isEmpty && _news.isEmpty) {
      return AppEmptyState(
        key: const ValueKey('voucher-empty'),
        title: 'Chưa có voucher',
        message: 'Ưu đãi và tin hot sẽ xuất hiện tại đây.',
        actionLabel: 'Tải lại',
        onAction: _load,
      );
    }

    return Column(
      key: const ValueKey('voucher-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterRow(
          selected: _filter,
          onChanged: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_filter != _VoucherFilter.news) ...[
          const SectionHeader(
            title: 'Voucher',
            subtitle: 'Mã giảm giá cho vé và combo.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (_vouchers.isEmpty)
            const AppEmptyState(
              title: 'Chưa có voucher',
              message: 'Voucher mới sẽ được cập nhật sau.',
            )
          else
            ..._vouchers.map(
              (voucher) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: VoucherCard(
                  title: voucher.title,
                  description: voucher.description,
                  metaLabel: voucher.expiryLabel,
                  category: voucher.category,
                  code: voucher.code,
                  onPressed: () => AppNotifier.info(
                    context,
                    title: 'Mã voucher',
                    description: voucher.code,
                  ),
                ),
              ),
            ),
        ],
        if (_filter != _VoucherFilter.voucher) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'Tin hot',
            subtitle: 'Cập nhật lịch mở bán và cụm rạp mới.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (_news.isEmpty)
            const AppEmptyState(
              title: 'Chưa có tin mới',
              message: 'Tin tức rạp sẽ được cập nhật sau.',
            )
          else
            ..._news.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: VoucherCard(
                  title: item.title,
                  description: item.description,
                  metaLabel: item.dateLabel,
                  category: item.category,
                  code: null,
                  actionLabel: 'Xem tin',
                  onPressed: () => AppNotifier.info(
                    context,
                    title: item.category,
                    description: item.title,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final _VoucherFilter selected;
  final ValueChanged<_VoucherFilter> onChanged;

  const _FilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterButton(
          label: 'Tất cả',
          selected: selected == _VoucherFilter.all,
          onPressed: () => onChanged(_VoucherFilter.all),
        ),
        const SizedBox(width: AppSpacing.sm),
        _FilterButton(
          label: 'Voucher',
          selected: selected == _VoucherFilter.voucher,
          onPressed: () => onChanged(_VoucherFilter.voucher),
        ),
        const SizedBox(width: AppSpacing.sm),
        _FilterButton(
          label: 'Tin hot',
          selected: selected == _VoucherFilter.news,
          onPressed: () => onChanged(_VoucherFilter.news),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _FilterButton({
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
