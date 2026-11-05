import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/report.dart';

class ReportImage extends StatelessWidget {
  final Report report;

  const ReportImage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final url = report.imageUrl;
    final fallback = ColoredBox(
      color: AppColors.chipBackground,
      child: Center(
        child: Icon(
          report.category.icon,
          size: 36,
          color: AppColors.textTertiary,
        ),
      ),
    );
    if (url.isEmpty) return fallback;
    if (!url.startsWith('http')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(color: AppColors.chipBackground),
      errorWidget: (_, _, _) => fallback,
    );
  }
}
