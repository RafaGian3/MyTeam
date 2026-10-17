import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../models/media_sosial_model.dart';

/// Modal Bottom Sheet Tambah / Edit Media Sosial (FR-02)
class FormMedsosDialog extends StatefulWidget {
  final MediaSosialModel? item;
  final Future<bool> Function(String nama, String link) onSave;

  const FormMedsosDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    MediaSosialModel? item,
    required Future<bool> Function(String nama, String link) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FormMedsosDialog(item: item, onSave: onSave),
    );
  }

  @override
  State<FormMedsosDialog> createState() => _FormMedsosDialogState();
}

class _FormMedsosDialogState extends State<FormMedsosDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _linkCtrl;
  bool _isSaving = false;

  static const List<String> _presetPlatforms = [
    'LinkedIn',
    'GitHub',
    'Instagram',
    'Portofolio Website',
    'GitLab',
    'Twitter / X',
  ];

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.item?.namaMediaSosial ?? 'LinkedIn');
    _linkCtrl = TextEditingController(text: widget.item?.linkMediaSosial ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      _namaCtrl.text.trim(),
      _linkCtrl.text.trim(),
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Media sosial berhasil disimpan!'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan media sosial.'),
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
                    child: const Icon(Icons.link_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item == null ? 'Tambah Media Sosial' : 'Edit Media Sosial',
                          style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        Text('Tautkan profil publik dan portofolio karya Anda', style: AppTextStyles.bodySm),
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

              // Pilih Platform Cepat
              Text('Pilih Platform', style: AppTextStyles.labelMd.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetPlatforms.map((platform) {
                  final isSelected = _namaCtrl.text.toLowerCase() == platform.toLowerCase();
                  return ChoiceChip(
                    label: Text(platform),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _namaCtrl.text = platform);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Custom Nama Platform
              TextFormField(
                controller: _namaCtrl,
                style: AppTextStyles.bodyMd,
                validator: (v) => Validators.validateRequired(v, 'Nama platform'),
                decoration: InputDecoration(
                  labelText: 'Nama Platform',
                  hintText: 'Misal: LinkedIn / GitHub',
                  prefixIcon: const Icon(Icons.public_rounded, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Link URL
              TextFormField(
                controller: _linkCtrl,
                style: AppTextStyles.bodyMd,
                keyboardType: TextInputType.url,
                validator: Validators.validateUrl,
                decoration: InputDecoration(
                  labelText: 'Tautan / URL Profil',
                  hintText: 'https://linkedin.com/in/... atau https://github.com/...',
                  prefixIcon: const Icon(Icons.link_outlined, color: AppColors.textMuted, size: 20),
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
                      : const Text('Simpan Media Sosial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
