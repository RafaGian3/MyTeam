import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../services/team_feed_service.dart';

/// Modal Bottom Sheet Formulir Pengajuan Bergabung ke Tim (FR-16 Refinement)
/// Sesuai PRD v1.0, DESIGN.md (Academic Emerald Synergy), dan Subbab 4.3.3.
/// PIC Modul 3: Rafa Gian Atthari (Modul 3)
class TeamApplicationBottomSheet extends StatefulWidget {
  final String idTim;
  final String namaTim;
  final List<dynamic> kebutuhanTim;
  final String? initialPosisi;
  final void Function(String posisi) onSuccess;

  const TeamApplicationBottomSheet({
    super.key,
    required this.idTim,
    required this.namaTim,
    required this.kebutuhanTim,
    this.initialPosisi,
    required this.onSuccess,
  });

  @override
  State<TeamApplicationBottomSheet> createState() =>
      _TeamApplicationBottomSheetState();
}

class _TeamApplicationBottomSheetState
    extends State<TeamApplicationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pesanController;

  String? _selectedPosisi;
  String? _selectedSkills;
  int _selectedQuota = 1;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pesanController = TextEditingController();

    // Inisialisasi posisi terpilih
    if (widget.kebutuhanTim.isNotEmpty) {
      dynamic initialItem;
      if (widget.initialPosisi != null && widget.initialPosisi!.trim().isNotEmpty) {
        initialItem = widget.kebutuhanTim.firstWhere(
          (k) =>
              (k['posisi_dibutuhkan'] ?? k['posisi'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase() ==
              widget.initialPosisi!.trim().toLowerCase(),
          orElse: () => widget.kebutuhanTim.first,
        );
      } else {
        initialItem = widget.kebutuhanTim.first;
      }

      _selectedPosisi = (initialItem['posisi_dibutuhkan'] ??
              initialItem['posisi'] ??
              'Anggota')
          .toString();
      _selectedSkills = (initialItem['keahlian_dibutuhkan'] ?? '').toString();
      _selectedQuota =
          (initialItem['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1;
    } else {
      _selectedPosisi = widget.initialPosisi ?? 'Anggota';
      _selectedSkills = '';
      _selectedQuota = 1;
    }
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  void _selectPosisi(dynamic k) {
    if (_isSubmitting) return;
    setState(() {
      _selectedPosisi = (k['posisi_dibutuhkan'] ?? k['posisi'] ?? 'Anggota').toString();
      _selectedSkills = (k['keahlian_dibutuhkan'] ?? '').toString();
      _selectedQuota = (k['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1;
      _errorMessage = null;
    });
  }

  Future<void> _submitApplication() async {
    if (_isSubmitting) return;

    if (_selectedPosisi == null || _selectedPosisi!.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Harap pilih posisi yang ingin Anda lamar.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final posisi = _selectedPosisi!.trim();
    final pesan = _pesanController.text.trim();

    try {
      await TeamFeedService.applyToTeam(
        idTim: widget.idTim,
        posisi: posisi,
        pesanPengajuan: pesan,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess(posisi);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.90;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── DRAG HANDLE ───
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── MODAL HEADER ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryOutline,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajukan Bergabung ke Tim',
                          style: AppTextStyles.headlineMd.copyWith(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.groups_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.namaTim,
                                style: AppTextStyles.bodySm.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),
            const Divider(height: 20, color: AppColors.border),

            // ─── FORM CONTENT (SCROLLABLE) ───
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alert Error Banner jika ada kegagalan validasi / server
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusDangerBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFCA5A5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.statusDangerText,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.statusDangerText,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ─── SEKSI 1: PILIH POSISI ───
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pilih Posisi yang Dilamar',
                            style: AppTextStyles.titleMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih salah satu posisi yang dibuka oleh pemilik tim:',
                        style: AppTextStyles.bodySm.copyWith(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (widget.kebutuhanTim.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryOutline),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tim ini membuka pendaftaran untuk posisi umum: "$_selectedPosisi".',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Column(
                          children: widget.kebutuhanTim.map((k) {
                            final posisiName = (k['posisi_dibutuhkan'] ??
                                    k['posisi'] ??
                                    'Anggota')
                                .toString();
                            final quota =
                                (k['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1;
                            final skillsRaw =
                                (k['keahlian_dibutuhkan'] ?? '').toString();
                            final skillList = skillsRaw
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();

                            final isSelected = _selectedPosisi?.trim().toLowerCase() ==
                                posisiName.trim().toLowerCase();

                            return InkWell(
                              onTap: _isSubmitting ? null : () => _selectPosisi(k),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primarySoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 1.6 : 1.0,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(20),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  posisiName,
                                                  style: AppTextStyles.titleMd.copyWith(
                                                    fontSize: 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w600,
                                                    color: isSelected
                                                        ? AppColors.primaryDark
                                                        : AppColors.text,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.primarySoft,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: AppColors.primaryOutline,
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Dicari $quota Orang',
                                                  style: AppTextStyles.labelSm.copyWith(
                                                    color: AppColors.primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (skillList.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 5,
                                              runSpacing: 5,
                                              children: skillList.map((skill) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors.primaryOutline
                                                          : AppColors.border,
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    skill,
                                                    style: AppTextStyles.bodySm.copyWith(
                                                      fontSize: 11,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : AppColors.textMuted,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // ─── SEKSI 2: RINGKASAN POSISI TERPILIH ───
                      if (_selectedPosisi != null && _selectedPosisi!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4), // Emerald tint
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryOutline,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.assignment_turned_in_rounded,
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
                                      'Posisi Terpilih:',
                                      style: AppTextStyles.bodySm.copyWith(
                                        fontSize: 10.5,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$_selectedPosisi (Dicari $_selectedQuota Orang)',
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    if (_selectedSkills != null &&
                                        _selectedSkills!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Syarat: $_selectedSkills',
                                        style: AppTextStyles.bodySm.copyWith(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
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
                        ),
                      ],

                      const SizedBox(height: 18),

                      // ─── SEKSI 3: PESAN PENGAJUAN (WAJIB) ───
                      Row(
                        children: [
                          const Icon(
                            Icons.rate_review_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pesan Pengajuan & Motivasi',
                            style: AppTextStyles.titleMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jelaskan alasan Anda tertarik bergabung, portofolio relevan, dan bagaimana Anda dapat berkontribusi pada tim ini:',
                        style: AppTextStyles.bodySm.copyWith(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _pesanController,
                        enabled: !_isSubmitting,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Saya memiliki pengalaman implementasi modul Flutter REST API dan bersedia berkontribusi aktif dalam penyusunan tugas tim...',
                          hintStyle: AppTextStyles.bodySm.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderFocused,
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.red.shade400,
                              width: 1.2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.8,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Pesan pengajuan wajib diisi.';
                          }
                          if (value.trim().length < 10) {
                            return 'Tuliskan pesan motivasi minimal 10 karakter.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // ─── NOTICE / PANDUAN NOTIFIKASI ───
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3), // Soft yellow warning/info
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFDE047),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 16,
                              color: Color(0xFFA16207),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pengajuan Anda akan berstatus "Menunggu". Notifikasi otomatis akan dikirim ke akun pemilik tim untuk ditinjau.',
                                style: AppTextStyles.bodySm.copyWith(
                                  fontSize: 11.5,
                                  color: const Color(0xFF854D0E),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ─── ACTION BUTTONS ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: AppColors.textMuted,
                          ),
                          child: Text(
                            'Batal',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008000), // Unand Emerald
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF9CA3AF),
                            elevation: _isSubmitting ? 0 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kirim Pengajuan',
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
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
          ],
        ),
      ),
    );
  }
}
