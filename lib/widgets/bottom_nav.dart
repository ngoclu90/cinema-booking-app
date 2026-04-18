import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class BottomNavItem {
  final String label;
  final IconData icon;

  const BottomNavItem({required this.label, required this.icon});
}

const List<BottomNavItem> bottomNavItems = [
  BottomNavItem(label: 'Trang chủ', icon: Icons.home_outlined),
  BottomNavItem(label: 'Phim', icon: Icons.movie_outlined),
  BottomNavItem(label: 'Vé', icon: Icons.confirmation_num_outlined),
  BottomNavItem(label: 'Rạp', icon: Icons.location_on_outlined),
  BottomNavItem(label: 'Tôi', icon: Icons.person_outline),
];

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black12,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(bottomNavItems.length, (index) {
            final item = bottomNavItems[index];
            final isActive = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: AppDurations.short,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.brandRed.withAlphaPercent(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        duration: AppDurations.short,
                        scale: isActive ? 1.14 : 1.0,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? AppTheme.brandRed
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlphaPercent(0.75),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: AppDurations.short,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? AppTheme.brandRed
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlphaPercent(0.7),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(item.label, maxLines: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
