import 'package:flutter/material.dart';

import '../../design_system/tokens/index.dart';
import 'app_header.dart';

class ScreenContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final Future<void> Function()? onRefresh;

  const ScreenContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg,
      92,
    ),
    this.physics,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics:
          physics ??
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(padding: padding, child: child),
        ),
      ],
    );

    return Column(
      children: [
        AppHeader(title: title, subtitle: subtitle, actions: actions),
        Expanded(
          child: onRefresh == null
              ? scrollView
              : RefreshIndicator(
                  color: AppColors.brandPrimary,
                  backgroundColor: AppColors.bgSurface,
                  onRefresh: onRefresh!,
                  child: scrollView,
                ),
        ),
      ],
    );
  }
}
