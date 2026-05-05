import 'package:flutter/material.dart';

import '../../design_system/tokens/index.dart';
import 'bottom_navbar.dart';

class AppShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Widget child;

  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
      ),
    );
  }
}
