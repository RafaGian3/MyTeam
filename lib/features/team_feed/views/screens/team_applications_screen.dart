import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../models/team_application_model.dart';
import '../../services/team_feed_service.dart';
import '../../../team_management/views/widgets/team_status_badge.dart';

/// Layar Daftar Pengajuan Bergabung Masuk Tim — FR-17
/// PIC Modul 3: Rafa Gian Atthari (2411522002)
class TeamApplicationsScreen extends StatefulWidget {
  final String idTim;
  final String? teamName;

  const TeamApplicationsScreen({
    super.key,
    required this.idTim,
    this.teamName,
  });

  @override
  State<TeamApplicationsScreen> createState() => _TeamApplicationsScreenState();
}

class _TeamApplicationsScreenState extends State<TeamApplicationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TeamApplicationsResult? _result;

  // Filter aktif: 'Semua' | 'Menunggu' | 'Diterima' | 'Ditolak'
  String _selectedFilter = 'Semua';
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await TeamFeedService.fetchTeamApplications(
        widget.idTim,
        status: _selectedFilter == 'Semua' ? null : _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _result = res;
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

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    _loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    final title = _result?.namaTim.isNotEmpty == true
        ? _result!.namaTim
        : (widget.teamName ?? 'Daftar Pengajuan Masuk');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.text,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pengajuan Bergabung Masuk',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: _loadApplications,
              tooltip: 'Segarkan Lamaran',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: _loadApplications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _result == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _result == null) {
      return _buildErrorState(_errorMessage!);
    }

    final summary = _result?.summary ?? const TeamApplicationsSummary();
    final apps = _result?.applications ?? [];

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // 1. Header Rekap Tim & Indikator Counter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildHeaderCard(summary),
          ),
        ),

        // 2. Filter Segmented Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildFilterTabs(summary),
          ),
        ),

        // 3. Status loading saat ganti filter
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

        // 4. Daftar Kartu Pelamar atau Empty State
        if (!_isLoading && apps.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          )
        else if (!_isLoading)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = apps[index];
                  return _buildApplicantCard(app);
                },
                childCount: apps.length,
              ),
            ),
          ),
      ],
    );
  }

  // ── Header Card & Status Recap ─────────────────────────────────────────────
  Widget _buildHeaderCard(TeamApplicationsSummary summary) {
    final teamName = _result?.namaTim.isNotEmpty == true
        ? _result!.namaTim
        : (widget.teamName ?? 'Tim Saya');
    final activityName = _result?.namaKegiatan ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative watermark circle
          Positioned(
            right: -24,
            bottom: -32,
            child: Icon(
              Icons.group_work_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Area Pemilik Tim',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (summary.menunggu > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_active_rounded,
                              size: 13,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${summary.menunggu} Perlu Diproses',
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  teamName,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                if (activityName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    activityName,
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                // Rekap Counter Badge FR-17
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSummaryPill(
                      icon: Icons.hourglass_top_rounded,
                      label: 'Menunggu',
                      count: summary.menunggu,
                      bg: const Color(0xFFFEF3C7),
                      fg: const Color(0xFF92400E),
                    ),
                    _buildSummaryPill(
                      icon: Icons.check_circle_rounded,
                      label: 'Diterima',
                      count: summary.diterima,
                      bg: const Color(0xFFDCFCE7),
                      fg: const Color(0xFF15803D),
                    ),
                    _buildSummaryPill(
                      icon: Icons.cancel_rounded,
                      label: 'Ditolak',
                      count: summary.ditolak,
                      bg: const Color(0xFFFEE2E2),
                      fg: const Color(0xFFB91C1C),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required IconData icon,
    required String label,
    required int count,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Segmented Tabs ──────────────────────────────────────────────────
  Widget _buildFilterTabs(TeamApplicationsSummary summary) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua', 'count': summary.total},
      {'key': 'Menunggu', 'label': 'Menunggu', 'count': summary.menunggu},
      {'key': 'Diterima', 'label': 'Diterima', 'count': summary.diterima},
      {'key': 'Ditolak', 'label': 'Ditolak', 'count': summary.ditolak},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final key = f['key'] as String;
          final label = f['label'] as String;
          final count = f['count'] as int;
          final isSelected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => _onFilterChanged(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Applicant Card ─────────────────────────────────────────────────────────
  Widget _buildApplicantCard(TeamApplicationModel app) {
    Color accentColor;
    if (app.isMenunggu) {
      accentColor = const Color(0xFFD97706);
    } else if (app.isDiterima) {
      accentColor = AppColors.statusSuccessText;
    } else {
      accentColor = AppColors.statusDangerText;
    }

    final isProcessing = _processingIds.contains(app.idPengajuanBergabungTim);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: app.isMenunggu
              ? AppColors.primaryOutline
              : AppColors.border,
          width: app.isMenunggu ? 1.4 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis aksen status vertikal 4px
              Container(
                width: 4.5,
                color: accentColor,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showDetailModal(app),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris 1: Foto, Nama, NIM & Badge Status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primarySoft,
                              backgroundImage:
                                  _resolveAvatarImage(app.fotoProfil),
                              child: _resolveAvatarImage(app.fotoProfil) == null
                                  ? Text(
                                      app.namaPengguna.isNotEmpty
                                          ? app.namaPengguna[0].toUpperCase()
                                          : '?',
                                      style: AppTextStyles.titleMd.copyWith(
                                        color: AppColors.primary,
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
                                  Text(
                                    app.namaPengguna,
                                    style: AppTextStyles.titleMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${app.nim} ${app.programStudi != null ? '• ${app.programStudi}' : ''}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ApplicationStatusBadge(status: app.statusPengajuan),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Baris 2: Posisi yang dilamar & waktu pengajuan
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryOutline,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.work_outline_rounded,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    app.posisi,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  app.relativeTime,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Baris 3: Cuplikan Pesan Pengajuan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  app.pesanPengajuan.trim(),
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.text,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Baris 4: Aksi Cepat / Navigasi Detail (FR-18 & FR-19)
                        Row(
                          children: [
                            if (app.isMenunggu) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isProcessing
                                      ? null
                                      : () => _confirmDecision(
                                            app,
                                            'ditolak',
                                          ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.statusDangerText,
                                    side: const BorderSide(
                                      color: Color(0xFFFCA5A5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Tolak',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isProcessing
                                      ? null
                                      : () => _confirmDecision(
                                            app,
                                            'diterima',
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Terima',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => _showDetailModal(app),
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                              ),
                              label: const Text(
                                'Detail',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primaryOutline,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail Pengajuan Modal (FR-18 Preview & Keputusan FR-19) ───────────────
  void _showDetailModal(TeamApplicationModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Modal
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primarySoft,
                            backgroundImage:
                                _resolveAvatarImage(app.fotoProfil),
                            child: _resolveAvatarImage(app.fotoProfil) == null
                                ? Text(
                                    app.namaPengguna.isNotEmpty
                                        ? app.namaPengguna[0].toUpperCase()
                                        : '?',
                                    style: AppTextStyles.headlineMd.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.namaPengguna,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIM: ${app.nim}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (app.programStudi != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${app.programStudi}${app.fakultas != null ? ' • ${app.fakultas}' : ''}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ApplicationStatusBadge(status: app.statusPengajuan),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 16),

                      // Informasi Akademik & Kontak
                      if (app.ipk != null || app.kontak != null) ...[
                        Row(
                          children: [
                            if (app.ipk != null)
                              Expanded(
                                child: _buildInfoItem(
                                  icon: Icons.grade_rounded,
                                  title: 'IPK Pelamar',
                                  value: app.ipk!,
                                  badgeColor: AppColors.primarySoft,
                                  textColor: AppColors.primaryDark,
                                ),
                              ),
                            if (app.ipk != null && app.kontak != null)
                              const SizedBox(width: 12),
                            if (app.kontak != null)
                              Expanded(
                                child: _buildInfoItem(
                                  icon: Icons.phone_android_rounded,
                                  title: 'Kontak WhatsApp',
                                  value: app.kontak!,
                                  badgeColor: const Color(0xFFE0F2FE),
                                  textColor: const Color(0xFF0369A1),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Posisi yang dilamar
                      Text(
                        'Posisi yang Dilamar',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryOutline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.posisi,
                                    style: AppTextStyles.titleMd.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dikirim pada ${app.formattedDate}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pesan Pengajuan / Surat Motivasi
                      Text(
                        'Pesan Pengajuan Bergabung',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          app.pesanPengajuan,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.text,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Aksi Keputusan (FR-19)
                      if (app.isMenunggu) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _confirmDecision(app, 'ditolak');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.statusDangerText,
                                  side: const BorderSide(
                                    color: Color(0xFFFCA5A5),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Tolak Lamaran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _confirmDecision(app, 'diterima');
                                },
                                icon: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Terima ke Tim',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: app.isDiterima
                                ? AppColors.statusSuccessBg
                                : AppColors.statusDangerBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                app.isDiterima
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: app.isDiterima
                                    ? AppColors.statusSuccessText
                                    : AppColors.statusDangerText,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  app.isDiterima
                                      ? 'Pelamar telah diterima dan menjadi anggota resmi tim Anda.'
                                      : 'Pengajuan pelamar ini telah ditolak.',
                                  style: TextStyle(
                                    color: app.isDiterima
                                        ? AppColors.statusSuccessText
                                        : AppColors.statusDangerText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi Keputusan (Terima / Tolak) ──────────────────────────────────
  Future<void> _confirmDecision(TeamApplicationModel app, String status) async {
    final isAccept = status == 'diterima';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAccept
                    ? AppColors.statusSuccessBg
                    : AppColors.statusDangerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAccept ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isAccept
                    ? AppColors.statusSuccessText
                    : AppColors.statusDangerText,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAccept ? 'Terima Pelamar?' : 'Tolak Pengajuan?',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isAccept
              ? 'Mahasiswa ${app.namaPengguna} akan langsung ditambahkan ke dalam anggota tim untuk posisi "${app.posisi}".'
              : 'Apakah Anda yakin ingin menolak pengajuan bergabung dari ${app.namaPengguna}?',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept
                  ? AppColors.primary
                  : AppColors.statusDangerText,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isAccept ? 'Ya, Terima' : 'Ya, Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeDecision(app.idPengajuanBergabungTim, status);
    }
  }

  Future<void> _executeDecision(String idPengajuan, String status) async {
    setState(() => _processingIds.add(idPengajuan));
    try {
      await TeamFeedService.respondToApplication(
        idPengajuan: idPengajuan,
        status: status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'diterima'
                  ? 'Pengajuan berhasil diterima! Pelamar telah menjadi anggota tim.'
                  : 'Pengajuan telah ditolak.',
            ),
            backgroundColor: status == 'diterima'
                ? AppColors.statusSuccessText
                : AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingIds.remove(idPengajuan));
      }
    }
  }

  // ── Helper Resolusi Avatar ────────────────────────────────────────────────
  ImageProvider? _resolveAvatarImage(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('profiles/') || trimmed.startsWith('storage/')) {
      final cleanPath = trimmed.startsWith('storage/')
          ? trimmed
          : 'storage/$trimmed';
      final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
      return NetworkImage('$rootUrl/$cleanPath');
    }
    return null;
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedFilter) {
      case 'Menunggu':
        title = 'Tidak Ada Lamaran Menunggu';
        subtitle =
            'Semua pengajuan yang masuk ke tim ini telah Anda proses.';
        icon = Icons.mark_email_read_outlined;
        break;
      case 'Diterima':
        title = 'Belum Ada Lamaran Diterima';
        subtitle =
            'Pelamar yang Anda terima akan dicatat dalam riwayat ini.';
        icon = Icons.person_add_disabled_outlined;
        break;
      case 'Ditolak':
        title = 'Tidak Ada Lamaran Ditolak';
        subtitle =
            'Pengajuan yang ditolak akan diarsipkan dalam filter ini.';
        icon = Icons.filter_none_outlined;
        break;
      default:
        title = 'Belum Ada Pengajuan Masuk';
        subtitle =
            'Ketika mahasiswa mengajukan diri untuk bergabung ke tim ini,\nlamaran mereka akan muncul di sini.';
        icon = Icons.inbox_rounded;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadApplications,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Muat Ulang'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primaryOutline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.statusDangerText,
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal Memuat Pengajuan',
              style: AppTextStyles.headlineMd.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadApplications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
