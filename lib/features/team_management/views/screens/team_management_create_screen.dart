import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/storage_service.dart';
import '../../models/platform_upload_file.dart';
import '../../models/team_model.dart';
import '../../services/team_draft_service.dart';
import '../../viewmodels/team_management_viewmodel.dart';
import '../widgets/kebutuhan_tim_tile.dart';
import '../widgets/team_drafts_modal.dart';

/// Halaman Buat Tim Baru — FR-08
/// Multi-step wizard: Langkah 1 (Info Tim), Langkah 2 (Kebutuhan Tim), Langkah 3 (Dokumen)
class TeamManagementCreateScreen extends StatefulWidget {
  final TeamManagementViewModel viewModel;
  final TeamDraftModel? initialDraft;

  const TeamManagementCreateScreen({
    super.key,
    required this.viewModel,
    this.initialDraft,
  });

  @override
  State<TeamManagementCreateScreen> createState() =>
      _TeamManagementCreateScreenState();
}

class _TeamManagementCreateScreenState
    extends State<TeamManagementCreateScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Step state (0-based index: 0=Langkah 1, 1=Langkah 2, 2=Langkah 3)
  int _currentStep = 0;

  // Controllers Step 1
  final _namaTimCtrl = TextEditingController();
  final _namaKegiatanCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  String _selectedKategori = 'Lomba';

  // Step 2: Kebutuhan Tim per-posisi (sama persis seperti edit modal)
  List<KebutuhanTimModel> _kebutuhan = [
    const KebutuhanTimModel(posisiDibutuhkan: '', keahlianDibutuhkan: ''),
  ];

  // Draf Lokal (Multi-Draft)
  String? _activeDraftId;
  int _totalDraftsCount = 0;
  TeamDraftModel? _latestDraft;
  bool _isDraftBannerDismissed = false;

  // Step 3: Dokumen
  final List<PlatformUploadFile> _dokumenFiles = [];

  // User info
  String _currentUserName = 'Ketua Tim';
  String _currentUserSub = 'Mahasiswa Unand • Pembuat Tim';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.initialDraft != null) {
      _applyDraft(widget.initialDraft!);
    }
    _checkExistingDrafts();
  }

  Future<void> _checkExistingDrafts() async {
    final drafts = await TeamDraftService.getAllDrafts();
    if (mounted) {
      setState(() {
        _totalDraftsCount = drafts.length;
        _latestDraft = drafts.isNotEmpty ? drafts.first : null;
      });
    }
  }

  Future<void> _saveDraft({bool asNew = false}) async {
    final kebutuhanToSave = _kebutuhan
        .where((k) =>
            k.posisiDibutuhkan.trim().isNotEmpty ||
            k.keahlianDibutuhkan.trim().isNotEmpty)
        .toList();

    final targetId = (asNew || _activeDraftId == null)
        ? 'draft_${DateTime.now().millisecondsSinceEpoch}'
        : _activeDraftId!;

    final draft = TeamDraftModel(
      idDraft: targetId,
      namaTim: _namaTimCtrl.text.trim(),
      namaKegiatan: _namaKegiatanCtrl.text.trim(),
      kategoriKegiatan: _selectedKategori,
      deskripsi: _deskripsiCtrl.text.trim(),
      kebutuhan: kebutuhanToSave.isNotEmpty ? kebutuhanToSave : _kebutuhan,
      savedAt: DateTime.now(),
    );

    await TeamDraftService.saveDraft(draft);
    if (mounted) {
      setState(() {
        _activeDraftId = draft.idDraft;
        _isDraftBannerDismissed = false;
      });
      _checkExistingDrafts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Draf "${draft.namaTim.isEmpty ? 'Tanpa Nama' : draft.namaTim}" berhasil disimpan ke daftar draf.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF008744),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDraftsModal() async {
    final selectedDraft = await TeamDraftsModal.show(
      context,
      activeDraftId: _activeDraftId,
    );
    _checkExistingDrafts();
    if (selectedDraft != null && mounted) {
      _applyDraft(selectedDraft, showFeedback: true);
    }
  }

  void _applyDraft(TeamDraftModel draft, {bool showFeedback = true}) {
    void updateFormValues() {
      _activeDraftId = draft.idDraft;
      _namaTimCtrl.text = draft.namaTim;
      _namaKegiatanCtrl.text = draft.namaKegiatan;
      _selectedKategori = draft.kategoriKegiatan.isNotEmpty
          ? draft.kategoriKegiatan
          : 'Lomba';
      _deskripsiCtrl.text = draft.deskripsi;
      if (draft.kebutuhan.isNotEmpty) {
        _kebutuhan = List.from(draft.kebutuhan);
      } else {
        _kebutuhan = [
          const KebutuhanTimModel(posisiDibutuhkan: '', keahlianDibutuhkan: ''),
        ];
      }
      _isDraftBannerDismissed = true;
    }

    if (mounted) {
      setState(updateFormValues);
    } else {
      updateFormValues();
    }

    if (showFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Draf "${draft.namaTim.isEmpty ? 'Tanpa Nama' : draft.namaTim}" berhasil dimuat ke formulir!',
            ),
            backgroundColor: const Color(0xFF008744),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    final nama = await StorageService.getNama();
    final nim = await StorageService.getNim();
    if (mounted) {
      setState(() {
        if (nama != null && nama.isNotEmpty) _currentUserName = nama;
        if (nim != null && nim.isNotEmpty) {
          _currentUserSub = 'NIM $nim • Ketua Tim';
        }
      });
    }
  }

  @override
  void dispose() {
    _namaTimCtrl.dispose();
    _namaKegiatanCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  // ── FILE PICKER (PDF + JPG + PNG) — Universal Web & Native
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true, // Wajib: memuat bytes file langsung di Web & Desktop/Mobile
      );
      if (result == null || result.files.isEmpty) return;

      for (final f in result.files) {
        Uint8List? bytes = f.bytes;
        String? filePath;

        // DI WEB: Jangan pernah akses f.path karena akan melempar exception
        if (!kIsWeb) {
          try {
            filePath = f.path;
            if (bytes == null && filePath != null) {
              final ioFile = File(filePath);
              if (await ioFile.exists()) {
                bytes = await ioFile.readAsBytes();
              }
            }
          } catch (e) {
            debugPrint('Error membaca file native path: $e');
          }
        }

        if (bytes == null || bytes.isEmpty) continue;
        final ext = (f.extension ?? '').toLowerCase();
        final jenis = ext == 'pdf' ? 'panduan' : 'poster';
        if (mounted) {
          setState(() {
            _dokumenFiles.add(PlatformUploadFile(
              name: f.name,
              bytes: bytes!,
              path: kIsWeb ? null : filePath,
              jenis: jenis,
            ));
          });
        }
      }
    } catch (e) {
      debugPrint('Error FilePicker: $e');
      // Fallback: jika FilePicker mengalami kendala, gunakan ImagePicker
      try {
        final picker = ImagePicker();
        final images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          for (final img in images) {
            final bytes = await img.readAsBytes();
            if (mounted) {
              setState(() {
                _dokumenFiles.add(PlatformUploadFile(
                  name: img.name,
                  bytes: bytes,
                  path: kIsWeb ? null : img.path,
                  jenis: 'poster',
                ));
              });
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Foto poster berhasil dipilih via fallback picker.',
                ),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memilih dokumen: $e',
            ),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _removeDocument(int index) {
    setState(() => _dokumenFiles.removeAt(index));
  }

  // ── STEP NAVIGATION
  void _goNext() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      // Validasi minimal 1 kebutuhan dengan posisi terisi
      final valid = _kebutuhan.any((k) => k.posisiDibutuhkan.trim().isNotEmpty);
      if (!valid) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tambahkan minimal 1 posisi yang dibutuhkan.'),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _handleSubmit();
    }
  }

  void _goPrev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleSubmit() async {
    // Filter kebutuhan yang posisinya tidak kosong
    final kebutuhan = _kebutuhan
        .where((k) => k.posisiDibutuhkan.trim().isNotEmpty)
        .toList();

    if (kebutuhan.isEmpty) {
      kebutuhan.add(const KebutuhanTimModel(
        posisiDibutuhkan: 'Anggota Tim',
        keahlianDibutuhkan: 'Kompeten di bidang terkait',
      ));
    }

    final success = await widget.viewModel.createTeam(
      namaTim: _namaTimCtrl.text.trim(),
      namaKegiatan: _namaKegiatanCtrl.text.trim(),
      kategoriKegiatan: _selectedKategori,
      deskripsi: _deskripsiCtrl.text.trim(),
      kebutuhan: kebutuhan,
      dokumenFiles: _dokumenFiles.isNotEmpty ? _dokumenFiles : null,
    );

    if (mounted) {
      if (success) {
        if (_activeDraftId != null) {
          await TeamDraftService.deleteDraft(_activeDraftId!);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tim berhasil dibuat dan dipublikasikan! 🎉'),
            backgroundColor: Color(0xFF008744),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.saveError ?? 'Gagal membuat tim.'),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Step Indicator (Pinned)
          _buildStepIndicator(),

          // ── Banner Draf Tersimpan jika ada draf dan belum di-dismiss
          if (_totalDraftsCount > 0 &&
              !_isDraftBannerDismissed &&
              _activeDraftId == null)
            _buildDraftBanner(),

          // ── Konten Form per Langkah
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _buildCurrentStep(),
              ),
            ),
          ),

          // ── Bottom CTA Bar (Pinned)
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── APPBAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF008744),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/logo-MyTeam.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Create Team',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      actions: [
        // Tombol Lihat Draf (menampilkan total jumlah draf)
        if (_totalDraftsCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: _openDraftsModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.drafts_rounded,
                      size: 15,
                      color: Color(0xFF008744),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Draf ($_totalDraftsCount)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF008744),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Tombol Simpan Draft
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => _saveDraft(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 15,
                    color: Color(0xFF008744),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _activeDraftId != null ? 'Update Draf' : 'Simpan Draft',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── DRAFT BANNER
  Widget _buildDraftBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_rounded,
                color: Color(0xFF008744), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tersedia $_totalDraftsCount draf tersimpan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF14532D),
                  ),
                ),
                Text(
                  _latestDraft == null || _latestDraft!.namaTim.isEmpty
                      ? 'Ketuk untuk melihat daftar draf tim'
                      : 'Terakhir: "${_latestDraft!.namaTim}"',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF166534),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openDraftsModal,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF008744),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF166534)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Tutup Banner',
            onPressed: () => setState(() => _isDraftBannerDismissed = true),
          ),
        ],
      ),
    );
  }

  // ── STEP INDICATOR (Selalu Terlihat & Proporsional)
  Widget _buildStepIndicator() {
    const stepTitles = ['Informasi Tim', 'Kebutuhan Tim', 'Dokumen'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Label teks langkah & nama tahap aktif
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LANGKAH ${_currentStep + 1} DARI 3',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF008744),
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                stepTitles[_currentStep],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Baris 2: Segmented progress bar (3 segmen proporsional)
          Row(
            children: List.generate(3, (i) {
              final isActive = i <= _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  height: 4.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isActive
                        ? const Color(0xFF008744)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Baris 3: Tiga Step Nodes (Kiri, Tengah, Kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final isDone = i < _currentStep;
              final isCurrent = i == _currentStep;
              final labels = ['Informasi', 'Kebutuhan', 'Dokumen'];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone || isCurrent
                          ? const Color(0xFF008744)
                          : const Color(0xFFE2E8F0),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? const Color(0xFF008744)
                          : isDone
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  // ─────────────────────────────────────────────
  // LANGKAH 1: INFORMASI TIM
  // ─────────────────────────────────────────────
  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFBBF7D0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_outlined,
                      color: Color(0xFF166534), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Dasar Tim',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Isi nama tim, kegiatan, kategori, dan deskripsi singkat. '
                        'Informasi ini akan tampil di halaman pencarian tim.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF166534),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nama Tim
          _buildInputLabel('Nama Tim'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _namaTimCtrl,
            hint: 'cth: Garuda Unand Tech',
            icon: Icons.badge_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama tim wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Nama Kegiatan
          _buildInputLabel('Nama Kegiatan / Kompetisi'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _namaKegiatanCtrl,
            hint: 'cth: Pekan Kreativitas Mahasiswa (PKM-K) 2026',
            icon: Icons.emoji_events_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Nama kegiatan wajib diisi'
                : null,
          ),
          const SizedBox(height: 14),

          // Kategori
          _buildInputLabel('Kategori Kegiatan'),
          const SizedBox(height: 6),
          _buildKategoriDropdown(),
          const SizedBox(height: 14),

          // Deskripsi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInputLabel('Deskripsi Tim & Target'),
              Text(
                'Maks. 300 kata',
                style: GoogleFonts.inter(
                    fontSize: 11.5, color: const Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _deskripsiCtrl,
            hint: 'Jelaskan tujuan, visi proyek, dan nilai tambah tim Anda...',
            icon: null,
            maxLines: 5,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Deskripsi tim wajib diisi'
                : null,
          ),
          const SizedBox(height: 14),

          // Pembuat Tim (Info Card)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  backgroundImage: AssetImage('assets/images/avatar_male.jpg'),
                  backgroundColor: Color(0xFFE2E8F0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _currentUserName,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 14, color: Color(0xFF008744)),
                        ],
                      ),
                      Text(
                        _currentUserSub,
                        style: GoogleFonts.inter(
                            fontSize: 11.5, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pembuat',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LANGKAH 2: KEBUTUHAN TIM
  // ─────────────────────────────────────────────
  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7D2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_outlined,
                      color: Color(0xFF3730A3), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kebutuhan Anggota Tim',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Setiap posisi memiliki nama peran, keahlian, dan kuota anggota '
                        'masing-masing. Pisahkan keahlian dengan koma.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF3730A3),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daftar KebutuhanTimTile
          ...List.generate(
            _kebutuhan.length,
            (i) => KebutuhanTimTile(
              kebutuhan: _kebutuhan[i],
              index: i,
              onRemove: () {
                if (_kebutuhan.length > 1) {
                  setState(() => _kebutuhan.removeAt(i));
                }
              },
              onChanged: (updated) => setState(() => _kebutuhan[i] = updated),
            ),
          ),
          const SizedBox(height: 4),

          // Tombol Tambah Posisi
          OutlinedButton.icon(
            onPressed: () => setState(() => _kebutuhan.add(
                  const KebutuhanTimModel(
                      posisiDibutuhkan: '', keahlianDibutuhkan: ''),
                )),
            icon:
                const Icon(Icons.add_rounded, size: 18, color: Color(0xFF008744)),
            label: Text(
              'Tambah Posisi Baru',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF008744),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side:
                  const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 17, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contoh: Posisi "Mobile Developer" dengan keahlian "Flutter, Dart, REST API".',
                    style: GoogleFonts.inter(
                        fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LANGKAH 3: DOKUMEN PENDUKUNG
  // ─────────────────────────────────────────────
  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFED7AA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.folder_open_outlined,
                    color: Color(0xFFC2410C), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dokumen Pendukung (Opsional)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C2D12),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Unggah poster kegiatan atau panduan teknis (PDF). '
                      'Ini membantu rekan memahami kegiatan Anda lebih baik.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFFC2410C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Daftar berkas terpilih
        if (_dokumenFiles.isNotEmpty) ...[
          ...List.generate(_dokumenFiles.length, (i) {
            final doc = _dokumenFiles[i];
            final isPdf = doc.name.toLowerCase().endsWith('.pdf');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isPdf
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image,
                      color: isPdf
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF0284C7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isPdf ? 'BERKAS PDF' : 'GAMBAR POSTER',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Color(0xFF64748B)),
                    onPressed: () => _removeDocument(i),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ],

        // Upload button
        InkWell(
          onTap: _pickDocument,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF86EFAC),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF008744),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pilih File dari Perangkat',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF008744),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mendukung format PDF, JPG, PNG (Maks. 10MB per file)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Supported format badges
                Wrap(
                  spacing: 6,
                  children: ['PDF', 'JPG', 'PNG'].map((ext) {
                    final isImage = ext != 'PDF';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isImage
                            ? const Color(0xFFE0F2FE)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ext,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isImage
                              ? const Color(0xFF0284C7)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Catatan jika tidak ada dokumen
        if (_dokumenFiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 17, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dokumen bersifat opsional. Tim tetap bisa diterbitkan tanpa dokumen.',
                    style: GoogleFonts.inter(
                        fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final isLastStep = _currentStep == 2;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol Kembali (hanya tampil jika bukan langkah 1)
              if (_currentStep > 0) ...[
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _goPrev,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFCBD5E1), width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_ios_rounded,
                            size: 13, color: Color(0xFF475569)),
                        const SizedBox(width: 6),
                        Text(
                          'Kembali',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Tombol Lanjut / Publikasikan
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                        widget.viewModel.isSaving ? null : _goNext,
                    icon: widget.viewModel.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(
                            isLastStep
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                    label: Text(
                      widget.viewModel.isSaving
                          ? 'Memproses...'
                          : isLastStep
                              ? 'Publikasikan Tim Sekarang'
                              : 'Lanjut ke Langkah ${_currentStep + 2}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008744),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF86EFAC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────
  Widget _buildInputLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 12.5,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: const Color(0xFF64748B))
            : null,
        filled: true,
        fillColor: const Color(0xFFF4F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008744), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedKategori,
      items: const [
        DropdownMenuItem(
            value: 'Lomba', child: Text('Lomba / Kompetisi Nasional')),
        DropdownMenuItem(
            value: 'Penelitian', child: Text('Penelitian / Riset Ilmiah')),
        DropdownMenuItem(
            value: 'Proyek', child: Text('Proyek / Start-up Mahasiswa')),
        DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _selectedKategori = val);
      },
      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.interests_outlined,
            size: 18, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF4F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008744), width: 1.5),
        ),
      ),
    );
  }
}
