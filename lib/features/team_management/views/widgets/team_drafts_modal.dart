import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../services/team_draft_service.dart';
import 'team_category_badge.dart';

/// Modal dialog / bottom sheet untuk melihat dan mengelola daftar draf formulir tim (Multi-Draft)
class TeamDraftsModal extends StatefulWidget {
  final String? activeDraftId;

  const TeamDraftsModal({super.key, this.activeDraftId});

  /// Helper untuk menampilkan modal daftar draf.
  /// Mengembalikan `TeamDraftModel` yang dipilih untuk diterapkan ke formulir,
  /// atau `null` jika ditutup.
  static Future<TeamDraftModel?> show(
    BuildContext context, {
    String? activeDraftId,
  }) {
    return showModalBottomSheet<TeamDraftModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeamDraftsModal(activeDraftId: activeDraftId),
    );
  }

  @override
  State<TeamDraftsModal> createState() => _TeamDraftsModalState();
}

class _TeamDraftsModalState extends State<TeamDraftsModal> {
  List<TeamDraftModel> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    final list = await TeamDraftService.getAllDrafts();
    if (mounted) {
      setState(() {
        _drafts = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDraft(String idDraft) async {
    await TeamDraftService.deleteDraft(idDraft);
    _loadDrafts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draf berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Draf?'),
        content: const Text(
          'Seluruh draf pembuatan tim yang tersimpan di perangkat ini akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDangerText,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TeamDraftService.clearAllDrafts();
      _loadDrafts();
    }
  }

  String _formatTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bookmark_rounded,
                      color: Color(0xFF008744), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Daftar Draf Tim',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_isLoading && _drafts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '${_drafts.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Pilih draf untuk melanjutkan pengisian formulir',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF64748B), size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body list
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF008744)),
                  )
                : _drafts.isEmpty
                    ? _buildEmptyState()
                    : _buildDraftsList(),
          ),

          // Bottom Bar (jika ada draf)
          if (!_isLoading && _drafts.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 10, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.delete_sweep_rounded,
                        size: 18, color: Color(0xFFDC2626)),
                    label: Text(
                      'Hapus Semua',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  Text(
                    '${_drafts.length} draf tersimpan',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.drafts_outlined,
                  size: 40, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Draf Tersimpan',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saat Anda mengisi formulir Buat Tim, klik "Simpan Draft" untuk menyimpan progres Anda di sini.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008744),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      itemCount: _drafts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final d = _drafts[i];
        final isActive = d.idDraft == widget.activeDraftId;
        final filledPosisi =
            d.kebutuhan.where((k) => k.posisiDibutuhkan.isNotEmpty).length;

        return Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFE2E8F0),
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Kategori + Status Aktif + Waktu Simpan
                Row(
                  children: [
                    TeamCategoryBadge(kategori: d.kategoriKegiatan),
                    const SizedBox(width: 8),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Sedang Diedit',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      _formatTime(d.savedAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Nama Tim
                Text(
                  d.namaTim.isEmpty ? 'Tanpa Nama Tim' : d.namaTim,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Nama Kegiatan
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.namaKegiatan.isEmpty
                            ? 'Belum ada nama kegiatan'
                            : d.namaKegiatan,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Posisi badge info
                if (filledPosisi > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined,
                          size: 13, color: Color(0xFF008744)),
                      const SizedBox(width: 4),
                      Text(
                        '$filledPosisi posisi kebutuhan telah ditentukan',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF008744),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Baris Aksi
                Row(
                  children: [
                    // Tombol Hapus Draf Ini
                    OutlinedButton.icon(
                      onPressed: () => _deleteDraft(d.idDraft),
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 15, color: Color(0xFFDC2626)),
                      label: Text(
                        'Hapus',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Spacer(),

                    // Tombol Gunakan Draf
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, d),
                      icon: const Icon(Icons.file_upload_outlined,
                          size: 15, color: Colors.white),
                      label: Text(
                        'Gunakan Draf',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008744),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
