import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../services/team_feed_service.dart';
import '../widgets/team_application_bottom_sheet.dart';

/// Halaman Detail Tim untuk Pencari Tim (FR-15)
/// Sesuai PRD v1.0, DESIGN.md (Academic Emerald Synergy), dan Subbab 4.3.2.
/// PIC Modul 3: Rafa Gian Atthari (Modul 3)
class TeamFeedDetailScreen extends StatefulWidget {
  final String idTim;
  final String? namaTim;

  const TeamFeedDetailScreen({
    super.key,
    required this.idTim,
    this.namaTim,
  });

  @override
  State<TeamFeedDetailScreen> createState() => _TeamFeedDetailScreenState();
}

class _TeamFeedDetailScreenState extends State<TeamFeedDetailScreen> {
  Map<String, dynamic>? _team;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await TeamFeedService.getTeamDetail(widget.idTim);
      if (mounted) {
        setState(() {
          _team = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // URL & ASSET RESOLVERS
  // ─────────────────────────────────────────────────────────────────────────
  String _resolveFileUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
    if (cleanPath.startsWith('storage/')) {
      return '$rootUrl/$cleanPath';
    }
    return '$rootUrl/storage/$cleanPath';
  }

  ImageProvider? _getAvatarImage(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
    if (cleanPath.startsWith('storage/')) {
      return NetworkImage('$rootUrl/$cleanPath');
    }
    return NetworkImage('$rootUrl/storage/$cleanPath');
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length.clamp(0, 2)).toUpperCase();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final titleText = _isLoading
        ? (widget.namaTim ?? 'Detail Tim')
        : (_team?['nama_tim'] ?? widget.namaTim ?? 'Detail Tim');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          titleText,
          style: AppTextStyles.titleMd.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
            onPressed: _fetchDetail,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: (!_isLoading && _team != null)
          ? _buildStickyBottomBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_team == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaCard(),
                  const SizedBox(height: 14),
                  _buildLeaderCard(),
                  const SizedBox(height: 14),
                  _buildDescriptionCard(),
                  const SizedBox(height: 14),
                  _buildPositionsCard(),
                  const SizedBox(height: 14),
                  _buildMembersCard(),
                  const SizedBox(height: 14),
                  _buildDocumentsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. HERO BANNER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    final t = _team!;
    final dokumenList = (t['dokumen_pendukung'] as List<dynamic>? ?? []);
    final posters = dokumenList.where((d) {
      final jenis = (d['jenis_dokumen'] ?? '').toString().toLowerCase();
      final path = (d['path_file'] ?? '').toString().toLowerCase();
      return jenis == 'poster' ||
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.webp');
    }).toList();

    final hasPoster = posters.isNotEmpty;
    final posterUrl = hasPoster ? _resolveFileUrl(posters[0]['path_file'] ?? '') : '';
    final namaTim = t['nama_tim'] as String? ?? '';
    final namaKegiatan = t['nama_kegiatan'] as String? ?? '';
    final kategori = t['kategori_kegiatan'] as String? ?? t['kategori'] as String? ?? 'Lainnya';
    final status = (t['status_tim'] as String? ?? 'terbuka').toLowerCase();
    final isOpen = status == 'terbuka';

    return Stack(
      children: [
        // Background Image or Emerald Gradient
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF004D00), Color(0xFF008000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: (hasPoster && posterUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(posterUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (hasPoster && posterUrl.isNotEmpty)
              ? null
              : Center(
                  child: Opacity(
                    opacity: 0.15,
                    child: const Icon(
                      Icons.diversity_3_rounded,
                      size: 140,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),

        // Gradient overlay for contrast
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withAlpha(20),
                Colors.black.withAlpha(180),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Badges on Top-Right
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryPill(kategori),
              const SizedBox(width: 8),
              _buildStatusPill(isOpen),
            ],
          ),
        ),

        // Title and Activity at the bottom of Banner
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaTim,
                style: AppTextStyles.headlineLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFEF3C7),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      namaKegiatan,
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withAlpha(230),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quick Poster Zoom trigger if poster exists
        if (hasPoster && posterUrl.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.black.withAlpha(120),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showImagePreviewDialog(posterUrl, 'Poster Kegiatan'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Lihat Poster',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. META CARD (SUMMARY METRICS)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMetaCard() {
    final t = _team!;
    final kebutuhan = (t['kebutuhan_tim'] as List<dynamic>? ?? []);
    final totalPosisiDibutuhkan = kebutuhan.fold<int>(
      0,
      (sum, item) => sum + ((item['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1),
    );
    final totalAnggota = (t['anggota_tim'] as List<dynamic>? ?? []).length + 1; // +1 untuk ketua

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetaStat(
            icon: Icons.group_add_rounded,
            color: AppColors.primary,
            title: 'Kebutuhan',
            value: '$totalPosisiDibutuhkan Kuota',
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          _buildMetaStat(
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF2563EB),
            title: 'Anggota Aktif',
            value: '$totalAnggota Orang',
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          _buildMetaStat(
            icon: Icons.category_rounded,
            color: const Color(0xFFD97706),
            title: 'Kategori',
            value: (t['kategori_kegiatan'] ?? t['kategori'] ?? 'Lainnya').toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaStat({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.bodySm.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. LEADER PROFILE CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLeaderCard() {
    final t = _team!;
    final pembuat = t['pembuat_tim'] as Map<String, dynamic>? ?? {};
    final namaKetua = (pembuat['nama_pengguna'] ?? t['nama_pengguna'] ?? 'Ketua Tim').toString();
    final fotoKetua = (pembuat['foto_profil'] ?? t['foto_profil'])?.toString();
    final nimKetua = (pembuat['nim'] ?? t['nim'])?.toString();
    final prodiKetua = (pembuat['program_studi'] ?? t['program_studi'])?.toString();
    final fakultasKetua = (pembuat['fakultas'] ?? t['fakultas'])?.toString();

    final avatarProvider = _getAvatarImage(fotoKetua);

    return _buildSectionCard(
      icon: Icons.person_pin_rounded,
      iconColor: AppColors.primary,
      title: 'Pembuat & Ketua Tim',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySoft,
            backgroundImage: avatarProvider,
            child: avatarProvider == null
                ? Text(
                    _getInitials(namaKetua),
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        namaKetua,
                        style: AppTextStyles.titleMd.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryOutline, width: 0.5),
                      ),
                      child: Text(
                        'Ketua',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (nimKetua != null && nimKetua.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'NIM: $nimKetua',
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (prodiKetua != null && prodiKetua.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fakultasKetua != null && fakultasKetua.isNotEmpty
                        ? '$prodiKetua • $fakultasKetua'
                        : prodiKetua,
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. DESCRIPTION CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDescriptionCard() {
    final t = _team!;
    final deskripsi = (t['deskripsi'] as String? ?? '').trim();

    return _buildSectionCard(
      icon: Icons.article_rounded,
      iconColor: AppColors.primary,
      title: 'Latar Belakang & Sasaran Tim',
      child: Text(
        deskripsi.isNotEmpty
            ? deskripsi
            : 'Tidak ada deskripsi detail yang dilampirkan oleh pembuat tim.',
        style: AppTextStyles.bodyMd.copyWith(
          color: const Color(0xFF374151),
          height: 1.6,
          fontSize: 13.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. POSITIONS & SKILLS CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPositionsCard() {
    final t = _team!;
    final kebutuhan = (t['kebutuhan_tim'] as List<dynamic>? ?? []);
    final userStatus = t['user_status'] as Map<String, dynamic>? ?? {};
    final isPembuat = userStatus['is_pembuat'] == true;
    final isAnggota = userStatus['is_anggota'] == true;
    final hasPending = userStatus['has_pending_application'] == true;
    final statusTim = (t['status_tim'] as String? ?? 'terbuka').toLowerCase();
    final isClosed = statusTim == 'ditutup';
    final isDisabled = isPembuat || isAnggota || hasPending || isClosed;

    return _buildSectionCard(
      icon: Icons.group_work_rounded,
      iconColor: AppColors.primary,
      title: 'Kebutuhan Anggota Tim (${kebutuhan.length} Posisi)',
      child: kebutuhan.isEmpty
          ? Text(
              'Belum ada rincian spesifik posisi yang dicari.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            )
          : Column(
              children: kebutuhan.map((k) {
                final posisi = (k['posisi_dibutuhkan'] ?? k['posisi'] ?? 'Anggota').toString();
                final jumlah = (k['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1;
                final rawKeahlian = (k['keahlian_dibutuhkan'] ?? '').toString();
                final skills = rawKeahlian
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                return InkWell(
                  onTap: isDisabled
                      ? null
                      : () => _handleAjukanBergabung(initialPosisi: posisi),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Posisi Header & Kuota Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.work_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      posisi,
                                      style: AppTextStyles.titleMd.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primaryOutline,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'Dicari $jumlah Orang',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!isDisabled) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF008000),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Lamar',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        if (skills.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Keahlian yang Disyaratkan:',
                            style: AppTextStyles.bodySm.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryOutline),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 11,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      skill,
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. REGISTERED MEMBERS CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMembersCard() {
    final t = _team!;
    final pembuat = t['pembuat_tim'] as Map<String, dynamic>? ?? {};
    final namaKetua = (pembuat['nama_pengguna'] ?? t['nama_pengguna'] ?? 'Ketua Tim').toString();
    final fotoKetua = (pembuat['foto_profil'] ?? t['foto_profil'])?.toString();
    final prodiKetua = (pembuat['program_studi'] ?? t['program_studi'])?.toString();

    final anggotaList = (t['anggota_tim'] as List<dynamic>? ?? []);
    final totalCount = anggotaList.length + 1;

    return _buildSectionCard(
      icon: Icons.badge_rounded,
      iconColor: AppColors.primary,
      title: 'Anggota Terdaftar ($totalCount)',
      child: Column(
        children: [
          // 1. Leader item
          _buildMemberRow(
            nama: namaKetua,
            posisi: 'Ketua Tim',
            prodi: prodiKetua,
            foto: fotoKetua,
            isLeader: true,
          ),

          // 2. Official joined members
          if (anggotaList.isNotEmpty) ...[
            const Divider(height: 16, color: AppColors.border),
            ...anggotaList.map((a) {
              final nama = (a['nama_pengguna'] ?? 'Anggota').toString();
              final posisi = (a['posisi'] ?? 'Anggota Tim').toString();
              final prodi = a['program_studi']?.toString();
              final foto = a['foto_profil']?.toString();
              return _buildMemberRow(
                nama: nama,
                posisi: posisi,
                prodi: prodi,
                foto: foto,
                isLeader: false,
              );
            }),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Belum ada anggota lain yang bergabung. Tim ini sedang mencari rekan kolaborasi!',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberRow({
    required String nama,
    required String posisi,
    String? prodi,
    String? foto,
    required bool isLeader,
  }) {
    final avatarProvider = _getAvatarImage(foto);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isLeader ? AppColors.primarySoft : const Color(0xFFF3F4F6),
            backgroundImage: avatarProvider,
            child: avatarProvider == null
                ? Text(
                    _getInitials(nama),
                    style: AppTextStyles.labelSm.copyWith(
                      color: isLeader ? AppColors.primary : AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nama,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                    ],
                  ],
                ),
                Text(
                  prodi != null && prodi.isNotEmpty ? '$posisi • $prodi' : posisi,
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 11,
                    color: isLeader ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isLeader ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. SUPPORTING DOCUMENTS CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDocumentsCard() {
    final t = _team!;
    final dokumen = (t['dokumen_pendukung'] as List<dynamic>? ?? []);

    return _buildSectionCard(
      icon: Icons.folder_open_rounded,
      iconColor: AppColors.primary,
      title: 'Dokumen Pendukung (${dokumen.length})',
      child: dokumen.isEmpty
          ? Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak ada poster atau buku panduan yang dilampirkan.',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            )
          : Column(
              children: dokumen.map((d) {
                final namaFile = (d['nama_file'] ?? 'Berkas Pendukung').toString();
                final pathFile = (d['path_file'] ?? '').toString();
                final jenis = (d['jenis_dokumen'] ?? 'dokumen').toString().toLowerCase();
                final fileUrl = _resolveFileUrl(pathFile);
                final isImage = jenis == 'poster' ||
                    pathFile.endsWith('.jpg') ||
                    pathFile.endsWith('.jpeg') ||
                    pathFile.endsWith('.png') ||
                    pathFile.endsWith('.webp');

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isImage
                              ? AppColors.primarySoft
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                          color: isImage ? AppColors.primary : const Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaFile,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isImage ? 'Poster Kegiatan' : 'Buku Panduan Teknis (PDF)',
                              style: AppTextStyles.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Buka Dokumen',
                        icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                        onPressed: () {
                          if (isImage && fileUrl.isNotEmpty) {
                            _showImagePreviewDialog(fileUrl, namaFile);
                          } else {
                            _showPdfInfoDialog(namaFile, fileUrl);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 8. STICKY BOTTOM BAR (CTA AJUKAN BERGABUNG)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStickyBottomBar() {
    final t = _team!;
    final userStatus = t['user_status'] as Map<String, dynamic>? ?? {};
    final isPembuat = userStatus['is_pembuat'] == true;
    final isAnggota = userStatus['is_anggota'] == true;
    final hasPending = userStatus['has_pending_application'] == true;
    final statusTim = (t['status_tim'] as String? ?? 'terbuka').toLowerCase();
    final isClosed = statusTim == 'ditutup';

    // Check disable state
    final isDisabled = isPembuat || isAnggota || hasPending || isClosed;

    String buttonLabel = 'Ajukan Bergabung';
    IconData buttonIcon = Icons.send_rounded;
    Color buttonBg = const Color(0xFF008000); // Primer CTA #008000
    Color buttonFg = Colors.white;
    BorderSide buttonBorder = BorderSide.none;

    if (isPembuat) {
      buttonLabel = 'Anda adalah Pembuat Tim';
      buttonIcon = Icons.verified_user_rounded;
      buttonBg = const Color(0xFFE5E7EB);
      buttonFg = const Color(0xFF4B5563);
    } else if (isAnggota) {
      buttonLabel = 'Anda Sudah Bergabung';
      buttonIcon = Icons.check_circle_rounded;
      buttonBg = AppColors.statusSuccessBg;
      buttonFg = AppColors.statusSuccessText;
      buttonBorder = const BorderSide(color: Color(0xFF86EFAC), width: 1.2);
    } else if (hasPending) {
      buttonLabel = 'Lamaran Terkirim — Menunggu Konfirmasi';
      buttonIcon = Icons.hourglass_top_rounded;
      buttonBg = AppColors.statusPendingBg;
      buttonFg = AppColors.statusPendingText;
      buttonBorder = const BorderSide(color: Color(0xFFFDE047), width: 1.2);
    } else if (isClosed) {
      buttonLabel = 'Perekrutan Telah Ditutup';
      buttonIcon = Icons.lock_rounded;
      buttonBg = const Color(0xFFE5E7EB);
      buttonFg = const Color(0xFF9CA3AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: Icon(buttonIcon, size: 18, color: buttonFg),
            label: Text(
              buttonLabel,
              style: AppTextStyles.labelLg.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: buttonFg,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBg,
              foregroundColor: buttonFg,
              disabledBackgroundColor: buttonBg,
              disabledForegroundColor: buttonFg,
              elevation: isDisabled ? 0 : 2,
              side: buttonBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isDisabled ? null : () => _handleAjukanBergabung(),
          ),
        ),
      ),
    );
  }

  void _handleAjukanBergabung({String? initialPosisi}) {
    if (_team == null) return;
    final t = _team!;
    final kebutuhan = (t['kebutuhan_tim'] as List<dynamic>? ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TeamApplicationBottomSheet(
          idTim: widget.idTim,
          namaTim: (t['nama_tim'] ?? 'Tim').toString(),
          kebutuhanTim: kebutuhan,
          initialPosisi: initialPosisi,
          onSuccess: (posisi) {
            // 1. Perbarui state tombol CTA dan user_status secara instan
            setState(() {
              if (_team != null && _team!['user_status'] is Map) {
                (_team!['user_status'] as Map)['has_pending_application'] = true;
              }
            });

            // 2. Sinkronkan detail tim secara hening di latar belakang
            TeamFeedService.getTeamDetail(widget.idTim).then((updated) {
              if (mounted) {
                setState(() {
                  _team = updated;
                });
              }
            }).catchError((_) {});

            // 3. Tampilkan SnackBar sukses Academic Emerald
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF004D00), // Primary Dark
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF86EFAC), width: 1.2),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                content: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF006400),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF86EFAC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pengajuan Berhasil Dikirim!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lamaran Anda untuk posisi "$posisi" telah diteruskan ke pemilik tim.',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFFDCFCE7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI HELPERS & MODALS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String kategori) {
    Color bg = AppColors.primarySoft;
    Color fg = AppColors.primary;

    switch (kategori) {
      case 'Lomba':
        bg = AppColors.categoryCompetitionBg;
        fg = AppColors.categoryCompetitionText;
        break;
      case 'Penelitian':
        bg = AppColors.categoryResearchBg;
        fg = AppColors.categoryResearchText;
        break;
      case 'Proyek':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        kategori,
        style: AppTextStyles.labelSm.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.statusSuccessBg : AppColors.statusDangerBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: 11,
            color: isOpen ? AppColors.statusSuccessText : AppColors.statusDangerText,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Terbuka' : 'Ditutup',
            style: AppTextStyles.labelSm.copyWith(
              color: isOpen ? AppColors.statusSuccessText : AppColors.statusDangerText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreviewDialog(String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: const Text('Gagal menampilkan poster.'),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfInfoDialog(String namaFile, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Buku Panduan Teknis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              namaFile,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Tautan berkas lokal:\n$url',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOADING SKELETON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal Memuat Detail Tim',
              style: AppTextStyles.headlineMd.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Terjadi kesalahan pada jaringan server.',
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _fetchDetail,
            ),
          ],
        ),
      ),
    );
  }
}
