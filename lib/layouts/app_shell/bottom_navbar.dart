import 'package:flutter/material.dart';

import '../../design_system/tokens/index.dart';

class BottomNavItem {
  final String label;
  final IconData icon;

  const BottomNavItem({required this.label, required this.icon});
}

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<BottomNavItem> items = [
    BottomNavItem(label: 'Trang chủ', icon: Icons.home_outlined),
    BottomNavItem(label: 'Phim', icon: Icons.local_movies_outlined),
    BottomNavItem(label: 'Voucher', icon: Icons.confirmation_number_outlined),
    BottomNavItem(label: 'Vé của tôi', icon: Icons.event_seat_outlined),
    BottomNavItem(label: 'Hồ sơ', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final active = selectedIndex == index;
            final color = active ? AppColors.brandPrimary : AppColors.textMuted;
            return Expanded(
              child: Semantics(
                button: true,
                selected: active,
                label: item.label,
                child: InkWell(
                  onTap: () => onTabSelected(index),
                  child: SizedBox.expand(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 24, color: color),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.captionStrong.copyWith(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
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
