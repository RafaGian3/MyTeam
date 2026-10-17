import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/platform_upload_file.dart';
import '../../models/team_model.dart';
import '../../viewmodels/team_management_viewmodel.dart';
import 'kebutuhan_tim_tile.dart';

/// Modal Pop-up Edit Tim (FR-10)
/// Menggantikan layar terpisah dengan Pop-up Modal Bottom Sheet yang responsif & modern.
class TeamManagementEditModal extends StatefulWidget {
  final TeamModel team;
  final TeamManagementViewModel viewModel;

  const TeamManagementEditModal({
    super.key,
    required this.team,
    required this.viewModel,
  });

  /// Helper statis untuk memunculkan Edit Tim sebagai pop up modal
  static Future<bool?> show(
    BuildContext context, {
    required TeamModel team,
    required TeamManagementViewModel viewModel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => TeamManagementEditModal(
        team: team,
        viewModel: viewModel,
      ),
    );
  }

  @override
  State<TeamManagementEditModal> createState() => _TeamManagementEditModalState();
}

class _TeamManagementEditModalState extends State<TeamManagementEditModal> {
  late final TextEditingController _namaTimCtrl;
  late final TextEditingController _namaKegiatanCtrl;
  late final TextEditingController _deskripsiCtrl;
  late List<KebutuhanTimModel> _kebutuhan;
  late String _statusTim;

  final List<PlatformUploadFile> _newDokumenFiles = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final t = widget.team;
    _namaTimCtrl = TextEditingController(text: t.namaTim);
    _namaKegiatanCtrl = TextEditingController(text: t.namaKegiatan);
    _deskripsiCtrl = TextEditingController(text: t.deskripsi);
    _kebutuhan = List.from(t.kebutuhanTim.isNotEmpty
        ? t.kebutuhanTim
        : [
            const KebutuhanTimModel(
                posisiDibutuhkan: '', keahlianDibutuhkan: '')
          ]);
    _statusTim = t.statusTim;
  }

  @override
  void dispose() {
    _namaTimCtrl.dispose();
    _namaKegiatanCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

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
            _newDokumenFiles.add(PlatformUploadFile(
              name: f.name,
              bytes: bytes!,
              path: kIsWeb ? null : filePath,
              jenis: jenis,
            ));
          });
        }
      }
    } catch (e) {
      debugPrint('Error FilePicker in modal: $e');
      try {
        final picker = ImagePicker();
        final images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          for (final img in images) {
            final bytes = await img.readAsBytes();
            if (mounted) {
              setState(() {
                _newDokumenFiles.add(PlatformUploadFile(
                  name: img.name,
                  bytes: bytes,
                  path: kIsWeb ? null : img.path,
                  jenis: 'poster',
                ));
              });
            }
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
          ),
        );
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.updateTeam(
      idTim: widget.team.idTim,
      namaTim: _namaTimCtrl.text.trim(),
      namaKegiatan: _namaKegiatanCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      statusTim: _statusTim,
      kebutuhan: _kebutuhan,
      dokumenFiles: _newDokumenFiles.isNotEmpty ? _newDokumenFiles : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Tim berhasil diperbarui.'
            : (widget.viewModel.saveError ?? 'Gagal memperbarui tim.')),
        backgroundColor:
            success ? AppColors.statusSuccessText : AppColors.statusDangerText,
        behavior: SnackBarBehavior.floating,
      ));
      if (success) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: !widget.viewModel.isSaving,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag Handle (Pinned)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            // ── Modal Header (Pinned)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryOutline),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Tim',
                          style: AppTextStyles.headlineMd.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Perbarui informasi & kebutuhan tim',
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 22),
                    onPressed: widget.viewModel.isSaving
                        ? null
                        : () => Navigator.pop(context),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.border),

            // ── Scrollable Form Area
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    // ── INFO: Kategori dikunci (FR-10)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.statusPendingBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.statusPendingText.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.statusPendingText.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_outline_rounded,
                                size: 14, color: AppColors.statusPendingText),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kategori kegiatan tidak dapat diubah setelah tim dibuat.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.statusPendingText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Kategori (Read-only)
                    _buildLabel('Kategori Kegiatan (Terkunci)'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category_outlined,
                              size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(
                            widget.team.kategoriKegiatan,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_rounded,
                                    size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Terkunci',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Nama Tim
                    _buildLabel('Nama Tim *'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _namaTimCtrl,
                      hint: 'Nama tim Anda',
                      prefixIcon: Icons.groups_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama tim wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Nama Kegiatan
                    _buildLabel('Nama Kegiatan *'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _namaKegiatanCtrl,
                      hint: 'Nama kompetisi / kegiatan',
                      prefixIcon: Icons.emoji_events_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama kegiatan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Deskripsi
                    _buildLabel('Deskripsi Tim *'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _deskripsiCtrl,
                      hint: 'Jelaskan tujuan dan target tim Anda...',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      maxLength: 300,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Deskripsi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Status Tim
                    _buildLabel('Status Rekrutmen Tim'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _statusTim,
                      items: [
                        DropdownMenuItem(
                          value: AppConstants.statusTimTerbuka,
                          child: Row(children: [
                            const Icon(Icons.lock_open_rounded,
                                size: 16, color: AppColors.statusSuccessText),
                            const SizedBox(width: 8),
                            Text('Terbuka', style: AppTextStyles.bodyMd),
                          ]),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.statusTimDitutup,
                          child: Row(children: [
                            const Icon(Icons.lock_rounded,
                                size: 16, color: AppColors.statusDangerText),
                            const SizedBox(width: 8),
                            Text('Ditutup', style: AppTextStyles.bodyMd),
                          ]),
                        ),
                      ],
                      onChanged: (v) => setState(() => _statusTim = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5)),
                      ),
                      style: AppTextStyles.bodyMd,
                      dropdownColor: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),

                    // ── Kebutuhan Anggota Section
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Kebutuhan Anggota',
                            style: AppTextStyles.titleMd
                                .copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: AppColors.primaryOutline),
                          ),
                          child: Text(
                            '${_kebutuhan.length} Posisi',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tentukan posisi dan keahlian yang dicari untuk tim.',
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: 12),
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
                        onChanged: (updated) =>
                            setState(() => _kebutuhan[i] = updated),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _kebutuhan.add(
                            const KebutuhanTimModel(
                                posisiDibutuhkan: '', keahlianDibutuhkan: ''),
                          )),
                      icon: const Icon(Icons.add_rounded,
                          size: 18, color: AppColors.primary),
                      label: Text('Tambah Posisi',
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primaryOutline, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tambah Dokumen Baru Section
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Dokumen & Poster',
                            style: AppTextStyles.titleMd
                                .copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dokumen yang sudah ada tetap tersimpan. Tambah dokumen baru di bawah.',
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: 10),

                    // Dokumen yang sudah ada (preview ringkas)
                    if (widget.team.dokumenPendukung.isNotEmpty) ...[
                      ...widget.team.dokumenPendukung.map((doc) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description_outlined,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doc.namaFile,
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    doc.jenisDokumen.toUpperCase(),
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 4),
                    ],

                    // File baru yang dipilih
                    if (_newDokumenFiles.isNotEmpty) ...[
                      ...List.generate(_newDokumenFiles.length, (i) {
                        final doc = _newDokumenFiles[i];
                        final isPdf = doc.name.toLowerCase().endsWith('.pdf');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.primaryOutline)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPdf
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.image_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc.name,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    isPdf
                                        ? 'DOKUMEN PANDUAN (PDF)'
                                        : 'POSTER KEGIATAN (GAMBAR)',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.textMuted),
                                onPressed: () => setState(() {
                                  _newDokumenFiles.removeAt(i);
                                }),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],

                    // Tombol Upload Picker
                    InkWell(
                      onTap: _pickDocument,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryOutline,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Unggah Dokumen Tambahan',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'PNG, JPG, atau PDF (Maks. 10MB)',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pinned Footer Actions
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: AppColors.surface,
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: widget.viewModel.isSaving
                            ? null
                            : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Batal',
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Simpan
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.viewModel.isSaving
                            ? null
                            : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryOutline,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: widget.viewModel.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Simpan Perubahan',
                                    style: AppTextStyles.labelLg
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: AppTextStyles.labelMd.copyWith(color: AppColors.text));
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySm,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textMuted, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.statusDangerText, width: 1.5)),
      ),
    );
  }
}
