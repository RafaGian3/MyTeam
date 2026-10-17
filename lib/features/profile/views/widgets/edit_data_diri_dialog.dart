import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../models/data_diri_model.dart';

/// Modal Bottom Sheet untuk Edit Biodata & Akademik (FR-01)
class EditDataDiriDialog extends StatefulWidget {
  final DataDiriModel? dataDiri;
  final Future<bool> Function({
    required String deskripsiSingkat,
    required String kontak,
    required String programStudi,
    required String fakultas,
    required double ipk,
  }) onSave;

  const EditDataDiriDialog({
    super.key,
    required this.dataDiri,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required DataDiriModel? dataDiri,
    required Future<bool> Function({
      required String deskripsiSingkat,
      required String kontak,
      required String programStudi,
      required String fakultas,
      required double ipk,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDataDiriDialog(dataDiri: dataDiri, onSave: onSave),
    );
  }

  @override
  State<EditDataDiriDialog> createState() => _EditDataDiriDialogState();
}

class _EditDataDiriDialogState extends State<EditDataDiriDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bioCtrl;
  late final TextEditingController _kontakCtrl;
  late final TextEditingController _prodiCtrl;
  late final TextEditingController _fakultasCtrl;
  late final TextEditingController _ipkCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(text: widget.dataDiri?.deskripsiSingkat ?? '');
    _kontakCtrl = TextEditingController(text: widget.dataDiri?.kontak ?? '');
    _prodiCtrl = TextEditingController(text: widget.dataDiri?.programStudi ?? 'Sistem Informasi');
    _fakultasCtrl = TextEditingController(text: widget.dataDiri?.fakultas ?? 'Teknologi Informasi');
    _ipkCtrl = TextEditingController(text: (widget.dataDiri?.ipk ?? 3.88).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _kontakCtrl.dispose();
    _prodiCtrl.dispose();
    _fakultasCtrl.dispose();
    _ipkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedIpk = double.parse(_ipkCtrl.text.trim());

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      deskripsiSingkat: _bioCtrl.text.trim(),
      kontak: _kontakCtrl.text.trim(),
      programStudi: _prodiCtrl.text.trim(),
      fakultas: _fakultasCtrl.text.trim(),
      ipk: parsedIpk,
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biodata & data akademik berhasil diperbarui!'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui biodata. Periksa koneksi backend.'),
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

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Biodata & Akademik', style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text('Perbarui data profil dan IPK terbaru Anda', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Bio
              _buildTextFormField(
                label: 'Deskripsi Singkat (Bio)',
                hint: 'Ceritakan latar belakang, fokus studi, atau minat Anda...',
                controller: _bioCtrl,
                maxLines: 3,
                validator: (v) => Validators.validateMinLength(v, 'Bio', 5),
              ),
              const SizedBox(height: 14),

              // Kontak
              _buildTextFormField(
                label: 'Nomor Kontak / WhatsApp',
                hint: 'Contoh: 081267891011',
                controller: _kontakCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 14),

              // Fakultas & Program Studi (2 Baris Terpisah)
              _buildTextFormField(
                label: 'Fakultas',
                hint: 'Contoh: Teknologi Informasi',
                controller: _fakultasCtrl,
                prefixIcon: Icons.account_balance_outlined,
                validator: (v) => Validators.validateRequired(v, 'Fakultas'),
              ),
              const SizedBox(height: 14),

              _buildTextFormField(
                label: 'Program Studi',
                hint: 'Contoh: Sistem Informasi',
                controller: _prodiCtrl,
                prefixIcon: Icons.school_outlined,
                validator: (v) => Validators.validateRequired(v, 'Program studi'),
              ),
              const SizedBox(height: 14),

              // IPK
              _buildTextFormField(
                label: 'Indeks Prestasi Kumulatif (IPK)',
                hint: 'Rentang 0.00 s/d 4.00 (contoh: 3.88)',
                controller: _ipkCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.stars_rounded,
                validator: Validators.validateIpk,
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
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd.copyWith(color: AppColors.text, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMd,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textMuted, size: 20) : null,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.statusDangerText)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.statusDangerText, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
