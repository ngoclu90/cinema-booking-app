import 'package:flutter/material.dart';

import '../components/ui/index.dart';
import '../data/services/news_service.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/news_item.dart';
import '../utils/app_notifier.dart';
import '../utils/image_helper.dart';
import 'news_detail_screen.dart';

class NewspaperScreen extends StatefulWidget {
  const NewspaperScreen({super.key});

  @override
  State<NewspaperScreen> createState() => _NewspaperScreenState();
}

class _NewspaperScreenState extends State<NewspaperScreen>
    with AutomaticKeepAliveClientMixin<NewspaperScreen> {
  final NewsService _newsService = NewsService();

  bool _loading = true;
  Object? _error;
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
      final response = await _newsService.getNews(page: 1, perPage: 10);
      if (!mounted) return;
      setState(() {
        _news = response?.data ?? const <NewsItem>[];
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
      title: 'Tin tức',
      subtitle: 'Tin tức và sự kiện nóng tại rạp',
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
        key: ValueKey('news-loading'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(height: 44),
          SizedBox(height: AppSpacing.md),
          AppSkeletonList(itemCount: 5),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('news-error'),
        title: 'Không tải được tin tức',
        message: 'Hãy thử lại để cập nhật tin nóng.',
        onRetry: _load,
      );
    }

    if (_news.isEmpty) {
      return AppEmptyState(
        key: const ValueKey('news-empty'),
        title: 'Chưa có bài báo mới',
        message: 'Các sự kiện rạp sẽ sớm được xuất hiện tại đây.',
        actionLabel: 'Tải lại',
        onAction: _load,
      );
    }

    return Column(
      key: const ValueKey('news-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._news.map((item) => _buildSafeNewsCard(item)),
      ],
    );
  }

  Widget _buildSafeNewsCard(NewsItem item) {
    final String categoryStr = (item.category.isNotEmpty) ? item.category : 'TIN TỨC';
    final String dateStr = item.dateLabel;
    final String titleStr = (item.title.isNotEmpty) ? item.title : 'Đang cập nhật nội dung';
    final String descStr = item.description;

    final String imageUrl = ImageHelper.getCorrectImageUrl(item.imageUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(item: item),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.zero,
          color: AppColors.bgSurface2,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.borderDefault.withOpacity(0.3),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            categoryStr.toUpperCase(),
                            style: AppTypography.captionStrong.copyWith(
                              color: AppColors.brandPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          dateStr,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      titleStr,
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (descStr.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        descStr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}