import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import 'dart:convert';

/// Halaman Detail Tim — View Only (dibuka dari kartu undangan)
/// Menggunakan GET /api/v1/teams/feed/:id_tim (FR-15)
/// PIC Modul 4: Diva Ramadhani (2411521017)
class TeamDetailViewScreen extends StatefulWidget {
  final String idTim;
  final String namaTim; // ditampilkan saat loading

  const TeamDetailViewScreen({
    super.key,
    required this.idTim,
    required this.namaTim,
  });

  @override
  State<TeamDetailViewScreen> createState() => _TeamDetailViewScreenState();
}

class _TeamDetailViewScreenState extends State<TeamDetailViewScreen> {
  Map<String, dynamic>? _team;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final resp = await ApiClient.get('/teams/feed/${widget.idTim}');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && json['success'] == true) {
        if (mounted) setState(() => _team = json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(json['message'] ?? 'Gagal memuat detail tim.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _isLoading ? widget.namaTim : (_team?['nama_tim'] ?? widget.namaTim),
          style: AppTextStyles.titleMd.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMsg != null
              ? _buildError()
              : _buildContent(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONTENT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final t = _team!;
    final kategori = t['kategori_kegiatan'] as String? ?? '';
    final status = t['status_tim'] as String? ?? '';
    final namaKegiatan = t['nama_kegiatan'] as String? ?? '';
    final deskripsi = t['deskripsi'] as String? ?? '';
    final namaPembuat = t['nama_pengguna'] as String? ?? '';
    final kebutuhan = (t['kebutuhan_tim'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    final anggota = (t['anggota_tim'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    final dokumen = (t['dokumen_pendukung'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Nama Tim
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.groups_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['nama_tim'] ?? '',
                              style: AppTextStyles.headlineMd.copyWith(fontSize: 17)),
                          if (namaKegiatan.isNotEmpty)
                            Text(namaKegiatan,
                                style: AppTextStyles.bodySm.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badges row
                Row(
                  children: [
                    _buildKategoriBadge(kategori),
                    const SizedBox(width: 8),
                    _buildStatusBadge(status),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Pembuat tim
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Pembuat: ',
                        style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted, fontSize: 12)),
                    Text(namaPembuat,
                        style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Deskripsi ────────────────────────────────────────────────────
          if (deskripsi.isNotEmpty) ...[
            _buildSection(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Tim',
              child: Text(deskripsi,
                  style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textMuted, height: 1.6, fontSize: 13)),
            ),
            const SizedBox(height: 12),
          ],

          // ── Kebutuhan Anggota ─────────────────────────────────────────────
          if (kebutuhan.isNotEmpty) ...[
            _buildSection(
              icon: Icons.person_search_rounded,
              title: 'Posisi yang Dibutuhkan',
              child: Column(
                children: kebutuhan.map((k) => _buildKebutuhanItem(k)).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Anggota Tim ──────────────────────────────────────────────────
          if (anggota.isNotEmpty) ...[
            _buildSection(
              icon: Icons.people_rounded,
              title: 'Anggota Tim (${anggota.length})',
              child: Column(
                children: anggota.map((a) => _buildAnggotaItem(a)).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Dokumen Pendukung ─────────────────────────────────────────────
          if (dokumen.isNotEmpty) ...[
            _buildSection(
              icon: Icons.attach_file_rounded,
              title: 'Dokumen Pendukung',
              child: Column(
                children: dokumen.map((d) => _buildDokumenItem(d)).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleMd.copyWith(fontSize: 14)),
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

  Widget _buildKebutuhanItem(Map<String, dynamic> k) {
    final posisi = k['posisi_dibutuhkan'] as String? ?? k['posisi'] as String? ?? '';
    final keahlian = k['keahlian_dibutuhkan'] as String? ?? '';
    final jumlah = k['jumlah_anggota_dibutuhkan'] ?? k['jumlah_dibutuhkan'] ?? 1;

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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$jumlah orang',
                style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary, fontSize: 10)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(posisi,
                    style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                if (keahlian.isNotEmpty)
                  Text(keahlian,
                      style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaItem(Map<String, dynamic> a) {
    final nama = a['nama_pengguna'] as String? ?? 'Anggota';
    final posisi = a['posisi'] as String? ?? '';
    final parts = nama.trim().split(' ');
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : nama.substring(0, nama.length.clamp(0, 2)).toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primarySoft,
            child: Text(inisial,
                style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                if (posisi.isNotEmpty)
                  Text(posisi,
                      style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenItem(Map<String, dynamic> d) {
    final judul = d['judul_dokumen'] as String? ?? 'Dokumen';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.description_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(judul,
                style: AppTextStyles.bodyMd.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriBadge(String kategori) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child:
          Text(kategori, style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 11)),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isOpen = status == 'terbuka';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.statusSuccessBg : AppColors.statusDangerBg,
        borderRadius: BorderRadius.circular(6),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryContainer),
          const SizedBox(height: 16),
          Text('Memuat detail tim...',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(_errorMsg!,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
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
}
