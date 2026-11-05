import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/report.dart';

class ReportImage extends StatelessWidget {
  final String url;
  final IconData icon;

  ReportImage({super.key, required Report report})
    : url = report.imageUrl,
      icon = report.category.icon;

  const ReportImage.path(this.url, {super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: AppColors.chipBackground,
      child: Center(child: Icon(icon, size: 36, color: AppColors.textTertiary)),
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
