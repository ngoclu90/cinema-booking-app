import 'package:flutter/material.dart';

import '../design_system/tokens/index.dart';
import '../models/news_item.dart';
import '../utils/image_helper.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem item;

  const NewsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String categoryStr = (item.category.isNotEmpty) ? item.category : 'TIN TỨC';
    final String titleStr = (item.title.isNotEmpty) ? item.title : 'Đang cập nhật nội dung';
    final String contentStr = (item.content.isNotEmpty) ? item.content : 'Nội dung đang được cập nhật.';
    final String imageUrl = ImageHelper.getCorrectImageUrl(item.imageUrl);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'news-hero-${item.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.borderDefault.withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 60,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: AppSpacing.md,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Quay lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        categoryStr.toUpperCase(),
                        style: AppTypography.captionStrong.copyWith(
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.dateLabel,
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
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(thickness: 1),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    contentStr,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}