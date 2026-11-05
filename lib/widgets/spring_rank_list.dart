import 'package:flutter/material.dart';

import '../core/theme/app_motion.dart';
import 'motion/spring_value.dart';

/// Fixed-height ranked rows whose positions spring, so rows physically swap
/// places when the order changes.
class SpringRankList extends StatelessWidget {
  final List<({String id, Widget child})> rows;
  final double rowHeight;

  const SpringRankList({
    super.key,
    required this.rows,
    required this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rows.length * rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < rows.length; i++)
            SpringValue(
              key: ValueKey(rows[i].id),
              value: i * rowHeight,
              from: rows.length * rowHeight,
              delay: Duration(milliseconds: 60 * i),
              spring: AppSprings.bouncy,
              child: SizedBox(height: rowHeight, child: rows[i].child),
              builder: (_, top, child) =>
                  Positioned(top: top, left: 0, right: 0, child: child!),
            ),
        ],
      ),
    );
  }
}
