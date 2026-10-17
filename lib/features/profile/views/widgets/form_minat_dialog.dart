import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../models/minat_model.dart';

/// Modal Bottom Sheet Tambah / Edit Minat (FR-03)
class FormMinatDialog extends StatefulWidget {
  final MinatModel? item;
  final Future<bool> Function(String minat, String desc) onSave;

  const FormMinatDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    MinatModel? item,
    required Future<bool> Function(String minat, String desc) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FormMinatDialog(item: item, onSave: onSave),
    );
  }

  @override
  State<FormMinatDialog> createState() => _FormMinatDialogState();
}

class _FormMinatDialogState extends State<FormMinatDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minatCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  static const List<String> _saranMinat = [
    'Mobile App Development',
    'Web Development',
    'Artificial Intelligence',
    'UI/UX Design & Research',
    'Data Science & Analytics',
    'Cyber Security',
    'Internet of Things (IoT)',
    'Competitive Programming',
  ];

  @override
  void initState() {
    super.initState();
    _minatCtrl = TextEditingController(text: widget.item?.minat ?? '');
    _descCtrl = TextEditingController(text: widget.item?.deskripsiMinat ?? '');
  }

  @override
  void dispose() {
    _minatCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      _minatCtrl.text.trim(),
      _descCtrl.text.trim(),
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minat berhasil disimpan!'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan minat.'),
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
                      color: AppColors.categoryCompetitionBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.categoryCompetitionText, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item == null ? 'Tambah Minat Bidang' : 'Edit Minat Bidang',
                          style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        Text('Tentukan topik kegiatan atau kompetisi yang Anda minati', style: AppTextStyles.bodySm),
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

              // Saran Minat Cepat
              Text('Rekomendasi Topik Minat', style: AppTextStyles.labelMd.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _saranMinat.map((saran) {
                  return ActionChip(
                    label: Text(saran),
                    labelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.categoryCompetitionText, fontSize: 11),
                    backgroundColor: AppColors.categoryCompetitionBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFFDE68A))),
                    onPressed: () => setState(() => _minatCtrl.text = saran),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Nama Minat
              TextFormField(
                controller: _minatCtrl,
                style: AppTextStyles.bodyMd,
                validator: (v) => Validators.validateMinLength(v, 'Bidang minat', 3),
                decoration: InputDecoration(
                  labelText: 'Bidang Minat',
                  hintText: 'Contoh: Mobile App Development',
                  prefixIcon: const Icon(Icons.interests_outlined, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi Minat
              TextFormField(
                controller: _descCtrl,
                style: AppTextStyles.bodyMd,
                maxLines: 2,
                validator: (v) => Validators.validateMinLength(v, 'Deskripsi minat', 5),
                decoration: InputDecoration(
                  labelText: 'Deskripsi Minat',
                  hintText: 'Jelaskan fokus kegiatan atau rencana yang ingin diikuti...',
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
                      : const Text('Simpan Minat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
