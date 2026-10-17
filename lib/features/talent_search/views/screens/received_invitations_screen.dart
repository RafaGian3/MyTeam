import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/config/app_config.dart';
import '../../services/talent_search_service.dart';
import '../../../team_feed/models/team_application_model.dart';
import '../../../team_feed/services/team_feed_service.dart';
import '../../../team_feed/views/screens/team_applications_screen.dart';
import '../../../team_management/services/team_management_service.dart';
import '../../../team_management/views/widgets/team_status_badge.dart';
import 'team_detail_view_screen.dart';

/// Halaman Notifikasi Undangan (FR-24 + FR-24b + FR-25)
/// Tab 1 — Undangan Masuk (FR-24): GET /applications/received-invitations
///          PATCH /applications/received-invitations/{id}/status
/// Tab 2 — Undangan Terkirim (FR-24b): GET /applications/sent-invitations
/// FR-25: Notifikasi respon otomatis dari backend (event)
/// PIC Modul 4: Diva Ramadhani (2411521017)
class ReceivedInvitationsScreen extends StatefulWidget {
  const ReceivedInvitationsScreen({super.key});

  @override
  State<ReceivedInvitationsScreen> createState() =>
      _ReceivedInvitationsScreenState();
}

class _ReceivedInvitationsScreenState extends State<ReceivedInvitationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String _myUserId = '';

  // ── Tab 1: Undangan Masuk ─────────────────────────────────────────────────
  List<Map<String, dynamic>> _received = [];
  bool _loadingReceived = true;
  String? _errorReceived;
  final Set<String> _processingIds = {};

  // ── Tab 2: Undangan Terkirim ──────────────────────────────────────────────
  List<Map<String, dynamic>> _sent = [];
  bool _loadingSent = true;
  String? _errorSent;

  // ── Tab 3: Lamaran Masuk ke Tim Milik Pengguna (FR-17) ─────────────────────
  List<TeamApplicationsResult> _teamApplicationsResults = [];
  bool _loadingTeamApps = true;
  String? _errorTeamApps;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _myUserId = await StorageService.getUserId() ?? '';
    await Future.wait([
      _loadReceived(),
      _loadSent(),
      _loadTeamApplications(),
    ]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Load Received ──────────────────────────────────────────────────────────
  Future<void> _loadReceived() async {
    if (!mounted) return;
    setState(() {
      _loadingReceived = true;
      _errorReceived = null;
    });
    try {
      final data = await TalentSearchService.getReceivedInvitations(_myUserId);
      if (mounted) setState(() => _received = data);
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorReceived = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingReceived = false);
    }
  }

  // ── Load Sent ─────────────────────────────────────────────────────────────
  Future<void> _loadSent() async {
    if (!mounted) return;
    setState(() {
      _loadingSent = true;
      _errorSent = null;
    });
    try {
      final data = await TalentSearchService.getSentInvitations(_myUserId);
      if (mounted) setState(() => _sent = data);
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorSent = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingSent = false);
    }
  }

  // ── Load Lamaran Masuk ke Tim (FR-17) ─────────────────────────────────────
  Future<void> _loadTeamApplications() async {
    if (!mounted) return;
    setState(() {
      _loadingTeamApps = true;
      _errorTeamApps = null;
    });

    try {
      final myTeams = await TeamManagementService.getMyTeams();
      final List<TeamApplicationsResult> results = [];

      for (final team in myTeams) {
        if (team.isOwner) {
          try {
            final appResult =
                await TeamFeedService.fetchTeamApplications(team.idTim);
            results.add(appResult);
          } catch (_) {
            // Abaikan error per tim
          }
        }
      }

      if (mounted) {
        setState(() {
          _teamApplicationsResults = results;
          _loadingTeamApps = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorTeamApps = e.toString().replaceFirst('Exception: ', '');
          _loadingTeamApps = false;
        });
      }
    }
  }

  // ── Respond Invitation (FR-24 + FR-25) ───────────────────────────────────
  Future<void> _respond(String id, String status) async {
    setState(() => _processingIds.add(id));
    try {
      final response = await TalentSearchService.respondInvitation(
        idPengajuanAnggota: id,
        status: status,
      );
      if (mounted) {
        final finalStatus = response['status_pengajuan'] as String;
        final message = response['message'] as String;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: finalStatus == 'diterima'
                ? AppColors.statusSuccessText
                : AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadReceived();
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
      if (mounted) setState(() => _processingIds.remove(id));
    }
  }

  Future<void> _confirmRespond(
    String id,
    String namaTim,
    String posisi,
    String status,
  ) async {
    final isAccept = status == 'diterima';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isAccept
                    ? AppColors.primarySoft
                    : AppColors.statusDangerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isAccept ? Icons.group_add_rounded : Icons.person_off_rounded,
                color: isAccept
                    ? AppColors.primaryContainer
                    : AppColors.statusDangerText,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAccept ? 'Konfirmasi bergabung' : 'Tolak undangan',
                    style: AppTextStyles.titleMd.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAccept ? 'Satu langkah lagi!' : 'Pastikan pilihanmu',
                    style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAccept
                  ? 'Kamu akan bergabung sebagai anggota tim:'
                  : 'Kamu akan menolak undangan bergabung ke:',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isAccept
                    ? AppColors.background
                    : const Color(0xFFFFF7F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAccept ? AppColors.border : AppColors.statusDangerBg,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isAccept
                          ? AppColors.primarySoft
                          : AppColors.statusDangerBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: isAccept
                          ? AppColors.primary
                          : AppColors.statusDangerText,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaTim,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (posisi.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Posisi: $posisi',
                            style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isAccept) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.statusPendingText,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Setelah diterima, kamu akan langsung tercatat sebagai anggota tim.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: Icon(
                    isAccept
                        ? Icons.check_circle_outline_rounded
                        : Icons.close_rounded,
                    size: 19,
                  ),
                  label: Text(
                    isAccept ? 'Ya, Terima Undangan' : 'Ya, Tolak Undangan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAccept
                        ? AppColors.primaryContainer
                        : AppColors.statusDangerText,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _respond(id, status);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pendingCount = _received
        .where((i) => i['status_pengajuan'] == 'menunggu')
        .length;
    final pendingTeamAppsCount = _teamApplicationsResults.fold<int>(
      0,
      (sum, res) => sum + res.summary.menunggu,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.text,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pusat Notifikasi & Lamaran',
              style: AppTextStyles.titleMd.copyWith(fontSize: 16),
            ),
            Text(
              'Kelola undangan tim dan lamaran masuk',
              style: AppTextStyles.bodySm.copyWith(fontSize: 11),
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
              onPressed: () => Future.wait([
                _loadReceived(),
                _loadSent(),
                _loadTeamApplications(),
              ]),
              tooltip: 'Segarkan',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryContainer,
          indicatorWeight: 2.5,
          labelColor: AppColors.primaryContainer,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTextStyles.labelMd.copyWith(fontSize: 12.5),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Undangan Masuk'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Undangan Terkirim'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Lamaran Masuk'),
                  if (pendingTeamAppsCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$pendingTeamAppsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildReceivedTab(pendingTeamAppsCount),
          _buildSentTab(),
          _buildTeamApplicationsTab(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: UNDANGAN MASUK
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReceivedTab(int pendingTeamAppsCount) {
    if (_loadingReceived) return _buildLoadingList();
    if (_errorReceived != null) {
      return _buildErrorState(_errorReceived!, _loadReceived);
    }
    if (_received.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryContainer,
        onRefresh: _loadReceived,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingTeamAppsCount > 0) ...[
              _buildIncomingApplicationsAlertBanner(pendingTeamAppsCount),
              const SizedBox(height: 32),
            ],
            const SizedBox(height: 40),
            Center(
              child: _buildEmptyState(
                icon: Icons.mail_outline_rounded,
                title: 'Belum ada undangan masuk',
                subtitle:
                    'Ketika pembuat tim mengundang Anda bergabung,\nundangan akan muncul di sini.',
              ),
            ),
          ],
        ),
      );
    }

    final menunggu = _received
        .where((i) => i['status_pengajuan'] == 'menunggu')
        .toList();
    final selesai = _received
        .where((i) => i['status_pengajuan'] != 'menunggu')
        .toList();

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _loadReceived,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pendingTeamAppsCount > 0) ...[
            _buildIncomingApplicationsAlertBanner(pendingTeamAppsCount),
            const SizedBox(height: 12),
          ],
          if (menunggu.isNotEmpty) ...[
            _buildSectionHeader(
              'Menunggu Keputusan',
              menunggu.length,
              Colors.amber,
            ),
            const SizedBox(height: 8),
            ...menunggu.map((inv) => _buildReceivedCard(inv, isPending: true)),
            const SizedBox(height: 16),
          ],
          if (selesai.isNotEmpty) ...[
            _buildSectionHeader(
              'Riwayat Undangan',
              selesai.length,
              AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            ...selesai.map((inv) => _buildReceivedCard(inv, isPending: false)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReceivedCard(
    Map<String, dynamic> inv, {
    required bool isPending,
  }) {
    final id = inv['id_pengajuan_anggota'] as String? ?? '';
    final idTim = inv['id_tim'] as String? ?? '';
    final namaTim = inv['nama_tim'] as String? ?? 'Tim';
    final namaKegiatan = inv['nama_kegiatan'] as String? ?? '';
    final kategori = inv['kategori_kegiatan'] as String? ?? '';
    final deskripsiTim = inv['deskripsi_tim'] as String? ?? '';
    final posisi = inv['posisi'] as String? ?? '';
    final pesan = inv['pesan_pengajuan'] as String? ?? '';
    final waktu = inv['waktu_pengajuan'] as String? ?? '';
    final status = inv['status_pengajuan'] as String? ?? 'menunggu';
    final isProcessing = _processingIds.contains(id);

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.primaryOutline : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 3.5,
                color: isPending
                    ? AppColors.primaryContainer
                    : _statusColor(status),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: icon + nama tim + tombol Detail Tim
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaTim,
                                  style: AppTextStyles.titleMd.copyWith(
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (namaKegiatan.isNotEmpty)
                                  Text(
                                    namaKegiatan,
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (kategori.isNotEmpty)
                                  Text(
                                    kategori,
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Tombol Lihat Detail Tim
                          if (idTim.isNotEmpty)
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeamDetailViewScreen(
                                    idTim: idTim,
                                    namaTim: namaTim,
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
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
                                      Icons.open_in_new_rounded,
                                      size: 11,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Detail Tim',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Deskripsi Tim
                      if (deskripsiTim.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          deskripsiTim,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      if (posisi.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryOutline),
                          ),
                          child: Text(
                            'Posisi ditawarkan: $posisi',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],

                      // Pesan Undangan
                      if (pesan.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  pesan,
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),

                      // Waktu + action buttons / status badge
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(waktu),
                            style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                          ),
                          const Spacer(),
                          if (isPending)
                            ..._buildActionButtons(
                              id,
                              namaTim,
                              posisi,
                              isProcessing,
                            )
                          else
                            _buildStatusBadge(status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return card;
  }

  List<Widget> _buildActionButtons(
    String id,
    String namaTim,
    String posisi,
    bool isProcessing,
  ) {
    if (isProcessing) {
      return [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primaryContainer,
            strokeWidth: 2,
          ),
        ),
      ];
    }
    return [
      GestureDetector(
        onTap: () => _confirmRespond(id, namaTim, posisi, 'ditolak'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.statusDangerBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.statusDangerText.withAlpha(60)),
          ),
          child: Text(
            'Tolak',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.statusDangerText,
              fontSize: 12,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _confirmRespond(id, namaTim, posisi, 'diterima'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Terima',
            style: AppTextStyles.labelMd.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: UNDANGAN TERKIRIM (FR-24b)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSentTab() {
    if (_loadingSent) return _buildLoadingList();
    if (_errorSent != null) return _buildErrorState(_errorSent!, _loadSent);
    if (_sent.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_rounded,
        title: 'Belum ada undangan terkirim',
        subtitle:
            'Undangan yang kamu kirim ke calon anggota\nakan muncul di sini beserta statusnya.',
      );
    }

    final menunggu = _sent
        .where((i) => i['status_pengajuan'] == 'menunggu')
        .toList();
    final diterima = _sent
        .where((i) => i['status_pengajuan'] == 'diterima')
        .toList();
    final ditolak = _sent
        .where((i) => i['status_pengajuan'] == 'ditolak')
        .toList();

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _loadSent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary chips
          _buildSentSummary(menunggu.length, diterima.length, ditolak.length),
          const SizedBox(height: 16),

          if (menunggu.isNotEmpty) ...[
            _buildSectionHeader(
              'Menunggu Respons',
              menunggu.length,
              Colors.amber,
            ),
            const SizedBox(height: 8),
            ...menunggu.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (diterima.isNotEmpty) ...[
            _buildSectionHeader(
              'Diterima',
              diterima.length,
              AppColors.statusSuccessText,
            ),
            const SizedBox(height: 8),
            ...diterima.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (ditolak.isNotEmpty) ...[
            _buildSectionHeader(
              'Ditolak',
              ditolak.length,
              AppColors.statusDangerText,
            ),
            const SizedBox(height: 8),
            ...ditolak.map(_buildSentCard),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSentSummary(int menunggu, int diterima, int ditolak) {
    return Row(
      children: [
        _summaryChip(
          'Menunggu',
          menunggu,
          Colors.amber.shade100,
          Colors.amber.shade700,
        ),
        const SizedBox(width: 8),
        _summaryChip(
          'Diterima',
          diterima,
          AppColors.statusSuccessBg,
          AppColors.statusSuccessText,
        ),
        const SizedBox(width: 8),
        _summaryChip(
          'Ditolak',
          ditolak,
          AppColors.statusDangerBg,
          AppColors.statusDangerText,
        ),
      ],
    );
  }

  Widget _summaryChip(String label, int count, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fg.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTextStyles.headlineMd.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: fg, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentCard(Map<String, dynamic> inv) {
    final namaTim = inv['nama_tim'] as String? ?? 'Tim';
    final namaKegiatan = inv['nama_kegiatan'] as String? ?? '';
    final kategori = inv['kategori_kegiatan'] as String? ?? '';
    final namaCalon = inv['nama_calon'] as String? ?? 'Calon Anggota';
    final prodiCalon = inv['prodi_calon'] as String? ?? '';
    final posisi = inv['posisi'] as String? ?? '';
    final pesan = inv['pesan_pengajuan'] as String? ?? '';
    final waktu = inv['waktu_pengajuan'] as String? ?? '';
    final status = inv['status_pengajuan'] as String? ?? 'menunggu';

    final parts = namaCalon.trim().split(' ');
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : namaCalon.substring(0, namaCalon.length.clamp(0, 2)).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3.5, color: _statusColor(status)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calon anggota
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              inisial,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaCalon,
                                  style: AppTextStyles.titleMd.copyWith(
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (prodiCalon.isNotEmpty)
                                  Text(
                                    prodiCalon,
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Nama tim info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.groups_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaTim,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (namaKegiatan.isNotEmpty)
                                    Text(
                                      namaKegiatan,
                                      style: AppTextStyles.bodySm.copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                  if (kategori.isNotEmpty)
                                    Text(
                                      kategori,
                                      style: AppTextStyles.bodySm.copyWith(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (posisi.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Posisi ditawarkan: $posisi',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ],

                      if (pesan.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '"$pesan"',
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(waktu),
                            style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                          ),
                          const Spacer(),
                          Text(
                            _statusDescription(status, namaCalon),
                            style: AppTextStyles.bodySm.copyWith(
                              fontSize: 10,
                              color: _statusColor(status),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusDescription(String status, String nama) {
    switch (status) {
      case 'diterima':
        return '$nama menerima undangan';
      case 'ditolak':
        return '$nama menolak undangan';
      default:
        return 'Menunggu respons $nama';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, int count, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMd.copyWith(fontSize: 15)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    String label;
    IconData icon;
    switch (status) {
      case 'diterima':
        bg = AppColors.statusSuccessBg;
        fg = AppColors.statusSuccessText;
        label = 'Diterima';
        icon = Icons.check_circle_rounded;
        break;
      case 'ditolak':
        bg = AppColors.statusDangerBg;
        fg = AppColors.statusDangerText;
        label = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPendingText;
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'diterima':
        return AppColors.statusSuccessText;
      case 'ditolak':
        return AppColors.statusDangerText;
      default:
        return AppColors.statusPendingText;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Hari ini';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildLoadingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 44),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleMd.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3: LAMARAN MASUK KE TIM MILIK PENGGUNA (FR-17)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIncomingApplicationsAlertBanner(int count) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _tabCtrl.animateTo(2),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Lamaran Masuk ke Tim Anda',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '$count Menunggu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ada $count mahasiswa menunggu konfirmasi bergabung pada tim Anda.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: const Color(0xFFB45309),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFD97706),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamApplicationsTab() {
    if (_loadingTeamApps) return _buildLoadingList();
    if (_errorTeamApps != null) {
      return _buildErrorState(_errorTeamApps!, _loadTeamApplications);
    }
    if (_teamApplicationsResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_work_outlined,
        title: 'Belum ada tim yang Anda buat',
        subtitle:
            'Buat tim baru di menu MyTeam untuk mulai menerima pendaftaran calon anggota.',
      );
    }

    final totalApps = _teamApplicationsResults.fold<int>(
      0,
      (sum, res) => sum + res.summary.total,
    );

    if (totalApps == 0) {
      return RefreshIndicator(
        color: AppColors.primaryContainer,
        onRefresh: _loadTeamApplications,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_ind_outlined,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum Ada Pelamar Masuk',
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ketika ada mahasiswa yang mengajukan diri untuk bergabung ke tim milik Anda, pengajuan mereka akan ditampilkan di sini.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: _loadTeamApplications,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Segarkan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primaryOutline),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _loadTeamApplications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teamApplicationsResults.length,
        itemBuilder: (context, index) {
          final res = _teamApplicationsResults[index];
          return _buildTeamApplicationGroupCard(res);
        },
      ),
    );
  }

  Widget _buildTeamApplicationGroupCard(TeamApplicationsResult res) {
    final pendingCount = res.summary.menunggu;
    final totalCount = res.summary.total;
    final hasPending = pendingCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPending ? AppColors.primaryOutline : AppColors.border,
          width: hasPending ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tim
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        res.namaTim,
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (hasPending)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$pendingCount Menunggu',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$totalCount Lamaran',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                if (res.namaKegiatan.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    res.namaKegiatan,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Summary baris kecil
                Row(
                  children: [
                    _buildMiniBadge(
                      '${res.summary.menunggu} Menunggu',
                      const Color(0xFFFEF3C7),
                      const Color(0xFF92400E),
                    ),
                    const SizedBox(width: 6),
                    _buildMiniBadge(
                      '${res.summary.diterima} Diterima',
                      const Color(0xFFDCFCE7),
                      const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 6),
                    _buildMiniBadge(
                      '${res.summary.ditolak} Ditolak',
                      const Color(0xFFFEE2E2),
                      const Color(0xFFB91C1C),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Cuplikan Pelamar (maksimal 2 ditampilkan di ringkasan)
          if (res.applications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada pelamar pada tim ini.',
                style: AppTextStyles.bodySm,
              ),
            )
          else ...[
            ...res.applications.take(2).map((app) {
              return InkWell(
                onTap: () => _openTeamApplications(res),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primarySoft,
                        backgroundImage: _resolveAppAvatar(app.fotoProfil),
                        child: _resolveAppAvatar(app.fotoProfil) == null
                            ? Text(
                                app.namaPengguna.isNotEmpty
                                    ? app.namaPengguna[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
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
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Posisi: ${app.posisi} • ${app.relativeTime}',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ApplicationStatusBadge(status: app.statusPengajuan),
                    ],
                  ),
                ),
              );
            }),
          ],

          const Divider(height: 1, color: AppColors.border),

          // Tombol Buka Kelola Pengajuan
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openTeamApplications(res),
                icon: const Icon(Icons.people_outline_rounded, size: 16),
                label: Text(
                  hasPending
                      ? 'Kelola Pengajuan Masuk ($pendingCount Menunggu)'
                      : 'Lihat Semua Pengajuan ($totalCount)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasPending
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  foregroundColor:
                      hasPending ? Colors.white : AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTeamApplications(TeamApplicationsResult res) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamApplicationsScreen(
          idTim: res.idTim,
          teamName: res.namaTim,
        ),
      ),
    );
    _loadTeamApplications();
  }

  Widget _buildMiniBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  ImageProvider? _resolveAppAvatar(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) return AssetImage(trimmed);
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('profiles/') || trimmed.startsWith('storage/')) {
      final cleanPath =
          trimmed.startsWith('storage/') ? trimmed : 'storage/$trimmed';
      final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
      return NetworkImage('$rootUrl/$cleanPath');
    }
    return null;
  }
}

