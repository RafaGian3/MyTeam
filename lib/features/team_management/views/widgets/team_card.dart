import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../models/team_model.dart';
import 'team_category_badge.dart';
import 'team_status_badge.dart';

/// Kartu tim berformat potret / petak ke bawah (FR-09)
/// Menampilkan poster/panduan tim di bagian atas, detail tim di tengah, dan aksi di bawah.
class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Poster / Panduan Image Header ──────────────
              _buildPosterHeader(),

              // ── 2. Konten Kartu Petak ke Bawah ────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Tim
                    Text(
                      team.namaTim,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Nama Kegiatan
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            team.namaKegiatan,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Posisi yang dibutuhkan (Chips)
                    if (team.kebutuhanTim.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children:
                            team.kebutuhanTim
                                .take(2)
                                .map(
                                  (k) => _PosisiChip(label: k.posisiDibutuhkan),
                                )
                                .toList()
                              ..addAll(
                                team.kebutuhanTim.length > 2
                                    ? [
                                        _PosisiChip(
                                          label:
                                              '+${team.kebutuhanTim.length - 2}',
                                          isCount: true,
                                        ),
                                      ]
                                    : [],
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),

                    // Baris Bawah: Anggota + Actions
                    Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${team.anggotaTim.length} anggota',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const Spacer(),

                        // Tombol Edit
                        if (onEdit != null) ...[
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Tombol Hapus
                        if (onDelete != null)
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.statusDangerBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 15,
                                color: AppColors.statusDangerText,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterHeader() {
    DokumenPendukungModel? posterDoc;
    DokumenPendukungModel? panduanDoc;

    for (final d in team.dokumenPendukung) {
      final name = d.namaFile.toLowerCase();
      if (d.jenisDokumen == 'poster' ||
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png')) {
        posterDoc = d;
        break;
      }
    }

    if (posterDoc == null) {
      for (final d in team.dokumenPendukung) {
        if (d.jenisDokumen == 'panduan' ||
            d.namaFile.toLowerCase().endsWith('.pdf')) {
          panduanDoc = d;
          break;
        }
      }
    }

    Widget imageContent;

    if (posterDoc != null) {
      final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
      final cleanPath = posterDoc.pathFile.startsWith('storage/')
          ? posterDoc.pathFile
          : 'storage/${posterDoc.pathFile}';
      final imageUrl = '$rootUrl/$cleanPath';

      imageContent = Image.network(
        imageUrl,
        width: double.infinity,
        height: 125,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderHeader(label: posterDoc!.namaFile),
      );
    } else if (panduanDoc != null) {
      imageContent = Container(
        width: double.infinity,
        height: 125,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.picture_as_pdf_rounded,
                size: 30,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  panduanDoc.namaFile,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF991B1B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      imageContent = _buildPlaceholderHeader();
    }

    return Stack(
      children: [
        imageContent,
        // Gradient overlay agar badge teks terbaca jelas
        Container(
          height: 125,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Status Badge (kiri atas)
        Positioned(
          top: 10,
          left: 10,
          child: TeamStatusBadge(status: team.statusTim),
        ),
        // Kategori Badge (kanan atas)
        Positioned(
          top: 10,
          right: 10,
          child: TeamCategoryBadge(kategori: team.kategoriKegiatan),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              team.isOwner ? 'Pemilik' : 'Anggota',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderHeader({String? label}) {
    return Container(
      width: double.infinity,
      height: 125,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF008744), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 36,
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PosisiChip extends StatelessWidget {
  final String label;
  final bool isCount;
  const _PosisiChip({required this.label, this.isCount = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCount ? const Color(0xFFF1F5F9) : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isCount ? const Color(0xFFCBD5E1) : AppColors.primaryOutline,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: isCount ? const Color(0xFF475569) : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
