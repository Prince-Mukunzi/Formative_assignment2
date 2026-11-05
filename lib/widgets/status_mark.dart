import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/report_status.dart';

class StatusMark extends StatelessWidget {
  final ReportStatus status;
  final Color color;
  final double size;

  const StatusMark({
    super.key,
    required this.status,
    required this.color,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: status.label,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MarkPainter(status, color)),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final ReportStatus status;
  final Color color;

  const _MarkPainter(this.status, this.color);

  static const _dashes = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final circle = Rect.fromCircle(center: center, radius: radius);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;

    switch (status) {
      case ReportStatus.awaitingApproval:
        const sweep = 2 * math.pi / _dashes;
        for (var i = 0; i < _dashes; i++) {
          canvas.drawArc(circle, i * sweep, sweep * 0.5, false, line);
        }
      case ReportStatus.inProgress:
        canvas.drawCircle(center, radius, line);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.55),
          -math.pi / 2,
          math.pi,
          true,
          fill,
        );
      case ReportStatus.resolved:
        canvas.saveLayer(Offset.zero & size, Paint());
        canvas.drawCircle(center, size.width / 2, fill);
        final tick = Path()
          ..moveTo(size.width * 0.29, size.height * 0.52)
          ..lineTo(size.width * 0.44, size.height * 0.67)
          ..lineTo(size.width * 0.72, size.height * 0.36);
        canvas.drawPath(tick, line..blendMode = BlendMode.clear);
        canvas.restore();
      case ReportStatus.declined:
        canvas.drawCircle(center, radius, line);
        final reach = radius * 0.4;
        canvas.drawLine(
          center.translate(-reach, -reach),
          center.translate(reach, reach),
          line,
        );
        canvas.drawLine(
          center.translate(reach, -reach),
          center.translate(-reach, reach),
          line,
        );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.status != status || old.color != color;
}
