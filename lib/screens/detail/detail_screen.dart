import 'package:flutter/material.dart';

import '../../models/team.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.team});

  final Team team;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // [LANGKAH 8] State catatan pribadi untuk tim ini
  String? _catatan;

  // [LANGKAH 8] Membuka halaman Form Catatan dan menunggu hasilnya
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    // Cek mounted setelah await sebelum menggunakan context/setState
    if (!mounted || hasil == null) return;

    setState(() {
      _catatan = hasil;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil disimpan'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final accent = team.isBlue ? AppColors.blue : AppColors.primary;
    final progress = team.members / team.capacity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar dengan warna aksen tim
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: team.isBlue ? AppColors.blue : AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      team.isBlue ? AppColors.blue : AppColors.primary,
                      team.isBlue
                          ? AppColors.blue.withValues(alpha: 0.7)
                          : AppColors.primaryDark.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge kategori
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team.categoryLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nama tim
                  Text(team.name, style: AppTextStyles.heading),
                  const SizedBox(height: 4),

                  // Nama kegiatan
                  Text(
                    team.activity,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 20),

                  // Deskripsi
                  _SectionCard(
                    title: 'Tentang Tim',
                    icon: Icons.info_outline_rounded,
                    color: accent,
                    child: Text(
                      team.description.isNotEmpty
                          ? team.description
                          : 'Tidak ada deskripsi tersedia.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kapasitas tim
                  _SectionCard(
                    title: 'Kapasitas Tim',
                    icon: Icons.people_outline_rounded,
                    color: accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${team.members} dari ${team.capacity} anggota',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              team.openPositions == 1
                                  ? 'Sisa 1 Posisi'
                                  : '${team.openPositions} Posisi Terbuka',
                              style: AppTextStyles.label.copyWith(
                                color: team.openPositions == 1
                                    ? AppColors.danger
                                    : AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.lavenderStrong,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Keahlian yang dibutuhkan
                  _SectionCard(
                    title: 'Keahlian Dibutuhkan',
                    icon: Icons.workspace_premium_outlined,
                    color: accent,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: team.requiredSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: accent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 7, color: accent),
                              const SizedBox(width: 5),
                              Text(
                                skill,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // [LANGKAH 8] Seksi Catatan Pribadi
                  _SectionCard(
                    title: 'Catatan Pribadi',
                    icon: Icons.sticky_note_2_outlined,
                    color: accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _catatan ?? 'Belum ada catatan.',
                          style: _catatan != null
                              ? AppTextStyles.body
                              : AppTextStyles.body
                                  .copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _bukaFormCatatan,
                            icon: const Icon(Icons.edit_note_rounded),
                            label: Text(
                              _catatan != null
                                  ? 'Ubah Catatan'
                                  : 'Tulis Catatan',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accent,
                              side: BorderSide(color: accent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Bergabung
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Ajukan Bergabung'),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget kartu seksi reusable untuk DetailScreen
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.label.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
