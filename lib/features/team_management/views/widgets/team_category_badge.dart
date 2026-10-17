import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Badge kategori kegiatan tim (DESIGN.md §2.1.C — Pill)
class TeamCategoryBadge extends StatelessWidget {
  final String kategori;
  const TeamCategoryBadge({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;
    final IconData icon;

    switch (kategori) {
      case 'Lomba':
        bg = AppColors.categoryCompetitionBg;
        text = AppColors.categoryCompetitionText;
        icon = Icons.emoji_events_rounded;
        break;
      case 'Penelitian':
        bg = AppColors.categoryResearchBg;
        text = AppColors.categoryResearchText;
        icon = Icons.science_outlined;
        break;
      case 'Proyek':
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF7C3AED);
        icon = Icons.rocket_launch_outlined;
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        text = AppColors.textMuted;
        icon = Icons.category_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: text),
          const SizedBox(width: 4),
          Text(
            kategori,
            style: AppTextStyles.labelSm.copyWith(color: text),
          ),
        ],
      ),
    );
  }
}
