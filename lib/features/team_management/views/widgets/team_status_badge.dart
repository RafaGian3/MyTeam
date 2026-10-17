import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Badge status tim: terbuka (hijau) / ditutup (merah)
class TeamStatusBadge extends StatelessWidget {
  final String status;
  const TeamStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool terbuka = status == 'terbuka';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: terbuka ? AppColors.statusSuccessBg : AppColors.statusDangerBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            terbuka ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: 11,
            color: terbuka
                ? AppColors.statusSuccessText
                : AppColors.statusDangerText,
          ),
          const SizedBox(width: 4),
          Text(
            terbuka ? 'Terbuka' : 'Ditutup',
            style: AppTextStyles.labelSm.copyWith(
              color: terbuka
                  ? AppColors.statusSuccessText
                  : AppColors.statusDangerText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge status pengajuan: menunggu / diterima / ditolak
class ApplicationStatusBadge extends StatelessWidget {
  final String status;
  const ApplicationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;
    final IconData icon;
    final String label;

    switch (status) {
      case 'diterima':
        bg = AppColors.statusSuccessBg;
        text = AppColors.statusSuccessText;
        icon = Icons.check_circle_outline_rounded;
        label = 'Diterima';
        break;
      case 'ditolak':
        bg = AppColors.statusDangerBg;
        text = AppColors.statusDangerText;
        icon = Icons.cancel_outlined;
        label = 'Ditolak';
        break;
      default:
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPendingText;
        icon = Icons.hourglass_empty_rounded;
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            label,
            style: AppTextStyles.labelSm.copyWith(color: text),
          ),
        ],
      ),
    );
  }
}
