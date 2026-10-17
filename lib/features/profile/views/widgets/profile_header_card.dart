import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/models/auth_user_model.dart';

/// Widget Header Profil Horizontal (Avatar di kiri, Nama & NIM di kanan, Tombol Pengaturan)
class ProfileHeaderCard extends StatelessWidget {
  final AuthUserModel user;
  final VoidCallback onGantiFoto;
  final VoidCallback? onSettings;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onGantiFoto,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Profil di Kiri (dengan tombol kamera untuk ganti foto)
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: _getAvatarImage(user.fotoProfil),
                child: (user.fotoProfil == null || user.fotoProfil!.isEmpty)
                    ? Text(
                        user.namaPengguna.isNotEmpty ? user.namaPengguna[0].toUpperCase() : 'U',
                        style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary, fontSize: 26),
                      )
                    : null,
              ),
              InkWell(
                onTap: onGantiFoto,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Nama & NIM di Kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.namaPengguna,
                  style: AppTextStyles.titleMd.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'NIM: ${user.nim}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mahasiswa Aktif',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Pengaturan di Pojok Kanan
          if (onSettings != null)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings_outlined, color: AppColors.text, size: 20),
                onPressed: onSettings,
                tooltip: 'Pengaturan Akun',
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    return NetworkImage(trimmed);
  }
}
