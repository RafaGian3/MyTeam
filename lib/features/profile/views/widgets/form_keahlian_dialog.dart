import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../models/keahlian_model.dart';

/// Modal Bottom Sheet Tambah / Edit Keahlian (FR-04)
class FormKeahlianDialog extends StatefulWidget {
  final KeahlianModel? item;
  final Future<bool> Function(String keahlian, String desc) onSave;

  const FormKeahlianDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    KeahlianModel? item,
    required Future<bool> Function(String keahlian, String desc) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FormKeahlianDialog(item: item, onSave: onSave),
    );
  }

  @override
  State<FormKeahlianDialog> createState() => _FormKeahlianDialogState();
}

class _FormKeahlianDialogState extends State<FormKeahlianDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keahlianCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  static const List<String> _saranKeahlian = [
    'Flutter & Dart',
    'UI/UX Design',
    'Figma',
    'Node.js & Express',
    'Python & AI',
    'Machine Learning',
    'MySQL / Database',
    'Project Management',
  ];

  @override
  void initState() {
    super.initState();
    _keahlianCtrl = TextEditingController(text: widget.item?.keahlian ?? '');
    _descCtrl = TextEditingController(text: widget.item?.deskripsiKeahlian ?? '');
  }

  @override
  void dispose() {
    _keahlianCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      _keahlianCtrl.text.trim(),
      _descCtrl.text.trim(),
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keahlian berhasil disimpan!'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan keahlian.'),
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
                    child: const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item == null ? 'Tambah Keahlian' : 'Edit Keahlian',
                          style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        Text('Tampilkan kompetensi teknis atau non-teknis Anda', style: AppTextStyles.bodySm),
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

              // Saran Keahlian Cepat
              Text('Rekomendasi Keahlian Populer', style: AppTextStyles.labelMd.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _saranKeahlian.map((saran) {
                  return ActionChip(
                    label: Text(saran),
                    labelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.primary, fontSize: 11),
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primaryOutline)),
                    onPressed: () => setState(() => _keahlianCtrl.text = saran),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Nama Keahlian
              TextFormField(
                controller: _keahlianCtrl,
                style: AppTextStyles.bodyMd,
                validator: (v) => Validators.validateMinLength(v, 'Nama keahlian', 2),
                decoration: InputDecoration(
                  labelText: 'Nama Keahlian (Skill)',
                  hintText: 'Contoh: Flutter & Dart',
                  prefixIcon: const Icon(Icons.code_rounded, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi Keahlian
              TextFormField(
                controller: _descCtrl,
                style: AppTextStyles.bodyMd,
                maxLines: 2,
                validator: (v) => Validators.validateMinLength(v, 'Deskripsi keahlian', 5),
                decoration: InputDecoration(
                  labelText: 'Deskripsi Keahlian',
                  hintText: 'Jelaskan tingkat penguasaan atau studi kasus proyek...',
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
                      : const Text('Simpan Keahlian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
