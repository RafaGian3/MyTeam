import 'package:flutter/material.dart';

import '../models/team.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team});

  final Team team;

  // (7) kirim tim yang dipilih ke layar Detail
  void _openDetail(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.detail, arguments: team);
  }

  @override
  Widget build(BuildContext context) {
    final progress = team.members / team.capacity;
    final accent = team.isBlue ? AppColors.blue : AppColors.primary;
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: accent, width: 4)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(label: team.categoryLabel, color: team.isBlue ? const Color(0xFFDCE6FF) : const Color(0xFFDDE5FF), textColor: team.isBlue ? AppColors.blue : AppColors.blue),
              const SizedBox(width: 6),
              if (!team.isBlue) const _Tag(label: 'IoT & AI', color: AppColors.primarySoft, textColor: AppColors.primaryDark),
              const Spacer(),
              const Icon(Icons.bookmark_border_rounded, color: AppColors.mutedText, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(team.name, style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text(team.activity, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Text('Dibutuhkan:', style: AppTextStyles.caption), const Spacer(), Text(team.openPositions == 1 ? 'Sisa 1 Posisi' : '${team.openPositions} Posisi Terbuka', style: AppTextStyles.label.copyWith(color: team.openPositions == 1 ? AppColors.danger : AppColors.primaryDark))]),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: team.requiredSkills.map((skill) => _SkillPill(label: skill, color: accent)).toList()),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [const Text('Kapasitas Tim', style: AppTextStyles.caption), const Spacer(), Text('${team.members}/${team.capacity} Anggota', style: AppTextStyles.caption.copyWith(color: AppColors.text, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 5),
          Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: AppColors.lavenderStrong, color: accent))), const SizedBox(width: 12), SizedBox(height: 34, child: FilledButton(onPressed: () => _openDetail(context), style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(horizontal: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Detail →')))]),
        ],
      ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color;
  final Color textColor;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Text(label, style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w700, fontSize: 10)));
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 7, color: color), const SizedBox(width: 4), Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.text, fontSize: 10, fontWeight: FontWeight.w600))]));
}
