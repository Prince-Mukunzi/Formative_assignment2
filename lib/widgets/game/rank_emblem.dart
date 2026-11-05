import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/game.dart';

class RankEmblem extends StatelessWidget {
  final Rank rank;
  final double size;

  const RankEmblem({super.key, required this.rank, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: Icon(rank.icon, size: size * 0.5, color: AppColors.brand),
    );
  }
}
