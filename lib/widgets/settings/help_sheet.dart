import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session.dart';
import '../app_sheet.dart';
import '../motion/pressable.dart';
import '../motion/spring_expand.dart';
import '../motion/spring_value.dart';

typedef _Answer = ({String question, String answer});

abstract final class HelpSheet {
  static void show(BuildContext context, Session? session) {
    AppSheet.show<void>(
      context,
      title: 'Help',
      icon: HugeIcons.strokeRoundedHelpCircle,
      child: Column(
        children: [for (final item in _answersFor(session)) _Question(item)],
      ),
    );
  }

  static List<_Answer> _answersFor(Session? session) => switch (session) {
    FacultySession() => const [
      (
        question: 'How does triage work?',
        answer:
            'Open the cards button in the bar. Swipe right to approve a '
            'report for your team, left to decline it.',
      ),
      (
        question: 'What moves us on the board?',
        answer:
            'Each fixed report earns 10 points. Every overdue report costs 15 '
            'and every reopened fix costs 10.',
      ),
      (
        question: 'When is a report overdue?',
        answer:
            'Each report has a deadline from the moment it is filed. The '
            'gauge on your queue rises as deadlines get close.',
      ),
      (
        question: 'A report belongs to another team',
        answer:
            'Open it and move it. The other team sees it straight away.',
      ),
    ],
    AdminSession() => const [
      (
        question: 'How do I add a team?',
        answer:
            'Tap the plus button, name the team and pick the categories it '
            'owns. A category belongs to one team at a time.',
      ),
      (
        question: 'How do I invite faculty?',
        answer:
            'Go to People and invite them by email with their team. They '
            'sign in on the Faculty card with that email.',
      ),
      (
        question: 'What is campus pressure?',
        answer:
            'Every open report adds weight, and late ones add the most. The '
            'gauge shows how much is building up across all teams.',
      ),
    ],
    _ => const [
      (
        question: 'How do I report something?',
        answer:
            'Tap the plus button, add a photo, pick a category and where it '
            'is. A photo and a clear description earn extra XP.',
      ),
      (
        question: 'How do I earn XP?',
        answer:
            'You earn XP when you file a report, when it is approved and '
            'fixed, when you check a fix, and when you back other reports.',
      ),
      (
        question: 'What happens after I report?',
        answer:
            'The right team approves it, fixes it and marks it fixed. Then '
            'you confirm the fix works, or reopen it.',
      ),
      (
        question: 'Can I change a report?',
        answer:
            'Yes, until a team approves it. Open the report to edit or '
            'delete it.',
      ),
    ],
  };
}

class _Question extends StatefulWidget {
  final _Answer item;

  const _Question(this.item);

  @override
  State<_Question> createState() => _QuestionState();
}

class _QuestionState extends State<_Question> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pressable(
          onTap: () => setState(() => _open = !_open),
          scale: 0.98,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: AppTextStyles.labelMedium,
                  ),
                ),
                SpringValue(
                  value: _open ? 1 : 0,
                  spring: AppSprings.bouncy,
                  builder: (_, t, child) =>
                      Transform.rotate(angle: t * math.pi / 2, child: child),
                  child: const Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SpringExpand(
          open: _open,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              widget.item.answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
