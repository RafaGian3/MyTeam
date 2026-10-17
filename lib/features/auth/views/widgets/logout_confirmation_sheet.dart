import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../services/auth_service.dart';
import '../../../../routes.dart';

/// Modal Bottom Sheet Konfirmasi Keluar Akun (FR-01: Akun & Riwayat Diri)
class LogoutConfirmationSheet extends StatefulWidget {
  final String? nama;
  final String? nim;

  const LogoutConfirmationSheet({
    super.key,
    this.nama,
    this.nim,
  });

  /// Menampilkan modal bottom sheet konfirmasi keluar akun
  static Future<void> show(
    BuildContext context, {
    String? nama,
    String? nim,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogoutConfirmationSheet(nama: nama, nim: nim),
    );
  }

  @override
  State<LogoutConfirmationSheet> createState() => _LogoutConfirmationSheetState();
}

class _LogoutConfirmationSheetState extends State<LogoutConfirmationSheet> {
  bool _isLoggingOut = false;
  String? _displayName;
  String? _displayNim;

  @override
  void initState() {
    super.initState();
    _displayName = widget.nama;
    _displayNim = widget.nim;
    if (_displayName == null || _displayNim == null) {
      _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    final nama = await StorageService.getNama();
    final nim = await StorageService.getNim();
    if (mounted) {
      setState(() {
        _displayName ??= nama;
        _displayNim ??= nim;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pop(context); // Tutup bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda telah berhasil keluar dari akun.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal keluar akun: ${e.toString()}'),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Danger Icon Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.statusDangerBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.statusDangerText.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.statusDangerText,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Konfirmasi Keluar Akun',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Apakah Anda yakin ingin keluar dari aplikasi MyTeam? Seluruh sesi login pada perangkat ini akan dihapus.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Account identity snippet
            if (_displayName != null || _displayNim != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        (_displayName != null && _displayName!.isNotEmpty)
                            ? _displayName![0].toUpperCase()
                            : 'M',
                        style: AppTextStyles.titleMd.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName ?? 'Mahasiswa Universitas Andalas',
                            style: AppTextStyles.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_displayNim != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'NIM: $_displayNim',
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Batal',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusDangerText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    label: Text(
                      _isLoggingOut ? 'Mengeluarkan...' : 'Ya, Keluar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
