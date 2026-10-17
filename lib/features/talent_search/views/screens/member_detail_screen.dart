import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/network/api_client.dart';
import '../../models/talent_member_model.dart';
import '../../services/talent_search_service.dart';

/// Halaman Detail Profil Calon Anggota (FR-22)
/// + Tombol Undang (FR-23: POST /applications/invite-member)
/// PIC Modul 4: Diva Ramadhani (2411521017)
class MemberDetailScreen extends StatefulWidget {
  final TalentMemberModel member;
  final String myUserId;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.myUserId,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  // ── Detail data (FR-22: GET /profile/detail/{id}) ────────────────────────
  Map<String, dynamic>? _detail;
  bool _loadingDetail = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    try {
      final data = await TalentSearchService.getMemberDetail(
        widget.member.idPengguna,
      );
      if (mounted) setState(() => _detail = data);
    } catch (e) {
      if (mounted) {
        setState(
          () => _detailError = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // ── FR-23: Kirim Undangan ─────────────────────────────────────────────────
  Future<void> _showInviteSheet() async {
    final myId = await StorageService.getUserId() ?? '';
    if (!mounted) return;

    if (myId == widget.member.idPengguna) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak dapat mengundang diri sendiri.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _InviteBottomSheet(member: widget.member, myUserId: myId),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_loadingDetail)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (_detailError != null)
            SliverFillRemaining(child: _buildErrorState())
          else
            SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.text,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004D00), Color(0xFF008000)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withAlpha(40),
                      backgroundImage:
                          (widget.member.fotoProfil != null &&
                              widget.member.fotoProfil!.isNotEmpty &&
                              widget.member.fotoProfil!.startsWith('http'))
                          ? NetworkImage(widget.member.fotoProfil!)
                                as ImageProvider
                          : null,
                      child:
                          (widget.member.fotoProfil == null ||
                              widget.member.fotoProfil!.isEmpty ||
                              !widget.member.fotoProfil!.startsWith('http'))
                          ? Text(
                              widget.member.inisial,
                              style: AppTextStyles.headlineLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.member.namaPengguna,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.member.programStudi} • ${widget.member.angkatan}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withAlpha(190),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: Text(
                    'Mahasiswa Aktif',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final dataDiri = _detail?['data_diri'] as Map<String, dynamic>?;
    final mediaSosial =
        (_detail?['media_sosial'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final minat =
        (_detail?['minat'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final keahlian =
        (_detail?['keahlian'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final pengalaman =
        (_detail?['pengalaman'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final timDiikuti =
        (_detail?['tim_yang_diikuti'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(keahlian.length, minat.length, pengalaman.length),
          const SizedBox(height: 16),

          if (dataDiri != null) ...[
            _buildCard(
              title: 'Tentang Saya',
              icon: Icons.person_rounded,
              children: [
                if ((dataDiri['deskripsi_singkat'] as String?)?.isNotEmpty ??
                    false)
                  Text(
                    dataDiri['deskripsi_singkat'] as String,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.school_rounded,
                  dataDiri['program_studi'] as String? ?? '-',
                ),
                _buildInfoRow(
                  Icons.business_rounded,
                  dataDiri['fakultas'] as String? ?? '-',
                ),
                if (dataDiri['ipk'] != null)
                  _buildInfoRow(
                    Icons.grade_rounded,
                    'IPK ${(double.tryParse(dataDiri['ipk'].toString()) ?? 0).toStringAsFixed(2)}',
                  ),
                if ((dataDiri['kontak'] as String?)?.isNotEmpty ?? false)
                  _buildInfoRow(
                    Icons.phone_rounded,
                    dataDiri['kontak'] as String,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (mediaSosial.isNotEmpty) ...[
            _buildCard(
              title: 'Media Sosial & Portofolio',
              icon: Icons.share_rounded,
              children: mediaSosial
                  .map(
                    (s) => _buildSocialRow(
                      s['nama_media_sosial'] as String? ?? '',
                      s['link_media_sosial'] as String? ?? '',
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          if (keahlian.isNotEmpty) ...[
            _buildCard(
              title: 'Keahlian Teknis',
              icon: Icons.auto_awesome_rounded,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: keahlian
                      .map(
                        (k) => _buildSkillPill(
                          k['keahlian'] as String? ?? '',
                          k['deskripsi_keahlian'] as String?,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (minat.isNotEmpty) ...[
            _buildCard(
              title: 'Minat & Bidang',
              icon: Icons.interests_rounded,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: minat
                      .map(
                        (m) => _buildInterestPill(m['minat'] as String? ?? ''),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (pengalaman.isNotEmpty) ...[
            _buildCard(
              title: 'Riwayat Pengalaman',
              icon: Icons.workspace_premium_rounded,
              children: pengalaman.map((e) => _buildExperienceItem(e)).toList(),
            ),
            const SizedBox(height: 12),
          ],

          if (timDiikuti.isNotEmpty) ...[
            _buildCard(
              title: 'Tim yang Diikuti',
              icon: Icons.groups_rounded,
              children: timDiikuti.map((t) => _buildTeamItem(t)).toList(),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int keahlian, int minat, int pengalaman) {
    return Row(
      children: [
        _statItem(keahlian.toString(), 'Keahlian'),
        const SizedBox(width: 8),
        _statItem(minat.toString(), 'Minat'),
        const SizedBox(width: 8),
        _statItem(pengalaman.toString(), 'Pengalaman'),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleMd.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMd.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(String nama, String link) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_socialIcon(nama), color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  link,
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.categoryResearchText,
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

  IconData _socialIcon(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('github')) return Icons.code_rounded;
    if (n.contains('linkedin')) return Icons.business_center_rounded;
    if (n.contains('instagram')) return Icons.camera_alt_rounded;
    if (n.contains('twitter') || n.contains('x'))
      return Icons.alternate_email_rounded;
    return Icons.link_rounded;
  }

  Widget _buildSkillPill(String keahlian, String? deskripsi) {
    return Tooltip(
      message: deskripsi ?? keahlian,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.primaryOutline),
        ),
        child: Text(
          keahlian,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.primary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestPill(String minat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.categoryResearchBg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.categoryResearchText.withAlpha(60)),
      ),
      child: Text(
        minat,
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.categoryResearchText,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exp['nama_kegiatan'] as String? ?? '-',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryCompetitionBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${exp['tahun'] ?? ''}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.categoryCompetitionText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  exp['peran'] as String? ?? '',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if ((exp['deskripsi_pengalaman'] as String?)?.isNotEmpty ??
                    false) ...[
                  const SizedBox(height: 4),
                  Text(
                    exp['deskripsi_pengalaman'] as String,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 3,
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

  Widget _buildTeamItem(Map<String, dynamic> tim) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
                  tim['nama_tim'] as String? ?? '-',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${tim['posisi'] ?? ''} • ${tim['nama_kegiatan'] ?? ''}',
                  style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildCategoryBadge(tim['kategori_kegiatan'] as String? ?? ''),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String kategori) {
    Color bg, fg;
    switch (kategori) {
      case 'Lomba':
        bg = AppColors.categoryCompetitionBg;
        fg = AppColors.categoryCompetitionText;
        break;
      case 'Penelitian':
        bg = AppColors.categoryResearchBg;
        fg = AppColors.categoryResearchText;
        break;
      default:
        bg = AppColors.primarySoft;
        fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        kategori,
        style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 10),
      ),
    );
  }

  Widget _buildErrorState() {
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
              _detailError ?? 'Gagal memuat profil.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDetail,
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

  Widget _buildBottomBar() {
    if (widget.myUserId == widget.member.idPengguna) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _showInviteSheet,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(
            'Ajak Bergabung ke Tim',
            style: AppTextStyles.labelLg.copyWith(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVITE BOTTOM SHEET (FR-23) — Dropdown pilih tim
// POST /api/v1/applications/invite-member
// ─────────────────────────────────────────────────────────────────────────────
class _InviteBottomSheet extends StatefulWidget {
  final TalentMemberModel member;
  final String myUserId;

  const _InviteBottomSheet({required this.member, required this.myUserId});

  @override
  State<_InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<_InviteBottomSheet> {
  final _msgCtrl = TextEditingController();
  bool _isSending = false;
  String? _errorMsg;

  List<Map<String, dynamic>> _myTeams = [];
  bool _loadingTeams = true;
  String? _selectedTeamId;
  String? _selectedTeamName;
  String? _selectedPosition;
  String? _teamsErrorMsg;

  Map<String, int> get _availablePositions {
    final team = _myTeams.where(
      (item) => item['id_tim']?.toString() == _selectedTeamId,
    );
    if (team.isEmpty) return {};

    final teamData = team.first;
    final needs = teamData['kebutuhan_tim'];
    if (needs is! List) return {};

    final requiredByPosition = <String, int>{};
    final positionNames = <String, String>{};
    for (final raw in needs) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final position = item['posisi_dibutuhkan']?.toString().trim() ?? '';
      if (position.isEmpty) continue;
      final key = position.toLowerCase();
      positionNames.putIfAbsent(key, () => position);
      requiredByPosition.update(
        key,
        (count) =>
            count +
            (int.tryParse(
                  item['jumlah_anggota_dibutuhkan']?.toString() ?? '',
                ) ??
                1),
        ifAbsent: () =>
            int.tryParse(item['jumlah_anggota_dibutuhkan']?.toString() ?? '') ??
            1,
      );
    }

    final currentByPosition = <String, int>{};
    final members = teamData['anggota_tim'];
    if (members is List) {
      for (final raw in members) {
        if (raw is! Map) continue;
        final position = raw['posisi']?.toString().trim() ?? '';
        if (position.isEmpty) continue;
        final key = position.toLowerCase();
        currentByPosition.update(key, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    return {
      for (final entry in requiredByPosition.entries)
        if (entry.value > (currentByPosition[entry.key] ?? 0))
          positionNames[entry.key]!:
              entry.value - (currentByPosition[entry.key] ?? 0),
    };
  }

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  Future<void> _loadMyTeams() async {
    try {
      final resp = await ApiClient.get('/teams/my-teams');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && json['success'] == true) {
        // Hanya tim yang DIBUAT pengguna (peran 'pemilik') yang boleh dipakai mengundang
        final teams = (json['data'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .where((t) => t['peran']?.toString() == 'pemilik')
            .toList();
        if (mounted) {
          setState(() {
            _myTeams = teams;
            _loadingTeams = false;
            _teamsErrorMsg = null;
            if (teams.length == 1) {
              _selectedTeamId = teams[0]['id_tim']?.toString();
              _selectedTeamName = teams[0]['nama_tim']?.toString();
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingTeams = false;
            _teamsErrorMsg =
                json['message']?.toString() ?? 'Gagal memuat daftar tim.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTeams = false;
          _teamsErrorMsg = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final pesan = _msgCtrl.text.trim();
    if (_selectedTeamId == null) {
      setState(() => _errorMsg = 'Pilih tim terlebih dahulu.');
      return;
    }
    if (_selectedPosition == null ||
        !_availablePositions.containsKey(_selectedPosition)) {
      setState(() => _errorMsg = 'Pilih posisi yang masih dibutuhkan tim.');
      return;
    }
    if (pesan.isEmpty) {
      setState(() => _errorMsg = 'Pesan undangan wajib diisi.');
      return;
    }
    setState(() {
      _isSending = true;
      _errorMsg = null;
    });
    try {
      await TalentSearchService.inviteMember(
        idTim: _selectedTeamId!,
        idPengguna: widget.member.idPengguna,
        posisi: _selectedPosition!,
        pesanPengajuan: pesan,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Undangan berhasil dikirim ke ${widget.member.namaPengguna}!',
            ),
            backgroundColor: AppColors.statusSuccessText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      widget.member.inisial,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajak ${widget.member.namaPengguna}',
                          style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                        ),
                        Text(
                          'Kirim undangan bergabung ke timmu',
                          style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),
              // ── Pilih Tim ─────────────────────────────────────────────────────
              Text(
                'Pilih Tim',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 6),
              if (_loadingTeams)
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else if (_teamsErrorMsg != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusDangerBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _teamsErrorMsg!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.statusDangerText,
                    ),
                  ),
                )
              else if (_myTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusPendingBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.statusPendingText.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.statusPendingText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kamu belum memiliki tim. Buat tim terlebih dahulu di tab MyTeam.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.statusPendingText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedTeamId != null
                          ? AppColors.borderFocused
                          : AppColors.border,
                      width: _selectedTeamId != null ? 1.5 : 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTeamId,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      borderRadius: BorderRadius.circular(10),
                      hint: Text(
                        'Pilih tim yang ingin kamu ajak...',
                        style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                      ),
                      items: _myTeams.map((team) {
                        final id = team['id_tim'] as String? ?? '';
                        final nama = team['nama_tim'] as String? ?? 'Tim';
                        final kegiatan = team['nama_kegiatan'] as String? ?? '';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nama,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (kegiatan.isNotEmpty)
                                Text(
                                  kegiatan,
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        final team = _myTeams.firstWhere(
                          (t) => t['id_tim'] == val,
                          orElse: () => {},
                        );
                        setState(() {
                          _selectedTeamId = val;
                          _selectedTeamName = team['nama_tim']?.toString();
                          _selectedPosition = null;
                        });
                      },
                    ),
                  ),
                ),
              if (_selectedTeamId != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.statusSuccessText,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tim "$_selectedTeamName" dipilih',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.statusSuccessText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
              if (_selectedTeamId != null &&
                  _availablePositions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Posisi yang Ditawarkan',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedPosition != null
                          ? AppColors.borderFocused
                          : AppColors.border,
                      width: _selectedPosition != null ? 1.5 : 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPosition,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      borderRadius: BorderRadius.circular(10),
                      hint: Text(
                        'Pilih posisi yang masih dibutuhkan...',
                        style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                      ),
                      items: _availablePositions.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                '${entry.key} (sisa ${entry.value})',
                                style: AppTextStyles.bodySm.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPosition = value),
                    ),
                  ),
                ),
              ] else if (_selectedTeamId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tim ini tidak memiliki posisi dengan kuota yang masih tersedia.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.statusPendingText,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // ── Pesan Undangan ────────────────────────────────────────────────
              Text(
                'Pesan Undangan',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _msgCtrl,
                style: AppTextStyles.bodyMd,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Halo ${widget.member.namaPengguna}, kami melihat keahlian Anda sangat cocok untuk tim kami...',
                  hintStyle: AppTextStyles.bodySm,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.borderFocused,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusDangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.statusDangerText,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_isSending ||
                              _myTeams.isEmpty ||
                              _selectedPosition == null ||
                              !_availablePositions.containsKey(
                                _selectedPosition,
                              ))
                          ? null
                          : _sendInvite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Kirim Undangan',
                              style: AppTextStyles.labelLg.copyWith(
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
