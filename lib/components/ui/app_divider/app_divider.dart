import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderDefault,
    );
  }
}
