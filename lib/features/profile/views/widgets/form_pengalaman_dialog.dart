import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../models/pengalaman_model.dart';

/// Modal Bottom Sheet Tambah / Edit Riwayat Pengalaman (FR-05)
class FormPengalamanDialog extends StatefulWidget {
  final PengalamanModel? item;
  final Future<bool> Function({
    required String namaKegiatan,
    required String peran,
    required int tahun,
    required String deskripsi,
  }) onSave;

  const FormPengalamanDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    PengalamanModel? item,
    required Future<bool> Function({
      required String namaKegiatan,
      required String peran,
      required int tahun,
      required String deskripsi,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FormPengalamanDialog(item: item, onSave: onSave),
    );
  }

  @override
  State<FormPengalamanDialog> createState() => _FormPengalamanDialogState();
}

class _FormPengalamanDialogState extends State<FormPengalamanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kegiatanCtrl;
  late final TextEditingController _peranCtrl;
  late final TextEditingController _tahunCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _kegiatanCtrl = TextEditingController(text: widget.item?.namaKegiatan ?? '');
    _peranCtrl = TextEditingController(text: widget.item?.peran ?? '');
    _tahunCtrl = TextEditingController(text: '${widget.item?.tahun ?? DateTime.now().year}');
    _descCtrl = TextEditingController(text: widget.item?.deskripsiPengalaman ?? '');
  }

  @override
  void dispose() {
    _kegiatanCtrl.dispose();
    _peranCtrl.dispose();
    _tahunCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedTahun = int.parse(_tahunCtrl.text.trim());

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      namaKegiatan: _kegiatanCtrl.text.trim(),
      peran: _peranCtrl.text.trim(),
      tahun: parsedTahun,
      deskripsi: _descCtrl.text.trim(),
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat pengalaman berhasil disimpan!'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan pengalaman.'),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item == null ? 'Tambah Riwayat Pengalaman' : 'Edit Pengalaman',
                          style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        Text('Kegiatan lomba, riset, atau proyek yang pernah diikuti', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Nama Kegiatan
              TextFormField(
                controller: _kegiatanCtrl,
                style: AppTextStyles.bodyMd,
                validator: (v) => Validators.validateMinLength(v, 'Nama kegiatan', 3),
                decoration: InputDecoration(
                  labelText: 'Nama Kegiatan / Lomba / Proyek',
                  hintText: 'Contoh: GEMASTIK XVII / PIMNAS 37 / PKM-KC',
                  prefixIcon: const Icon(Icons.emoji_events_outlined, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Peran dalam Tim (Baris 1)
              TextFormField(
                controller: _peranCtrl,
                style: AppTextStyles.bodyMd,
                validator: (v) => Validators.validateMinLength(v, 'Peran kegiatan', 2),
                decoration: InputDecoration(
                  labelText: 'Peran dalam Tim',
                  hintText: 'Contoh: Mobile Developer / Ketua Tim',
                  prefixIcon: const Icon(Icons.person_pin_outlined, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Tahun Pelaksanaan (Baris 2)
              TextFormField(
                controller: _tahunCtrl,
                style: AppTextStyles.bodyMd,
                keyboardType: TextInputType.number,
                validator: Validators.validateTahun,
                decoration: InputDecoration(
                  labelText: 'Tahun Pelaksanaan',
                  hintText: 'Contoh: 2025',
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 18),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi Pengalaman
              TextFormField(
                controller: _descCtrl,
                style: AppTextStyles.bodyMd,
                maxLines: 4,
                validator: (v) => Validators.validateMinLength(v, 'Deskripsi pengalaman', 10),
                decoration: InputDecoration(
                  labelText: 'Deskripsi Pengalaman & Kontribusi',
                  hintText: 'Jelaskan tugas, teknologi yang digunakan, serta pencapaian selama kegiatan...',
                  prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Pengalaman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
