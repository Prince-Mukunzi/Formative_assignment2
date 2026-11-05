import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}
