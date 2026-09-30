import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/data_diri.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';

// FR-01: Form tambah dan edit data diri pengguna
// Mode tambah: arguments == null → field kosong
// Mode edit:   arguments == DataDiri yang ada → field terisi
class DataDiriFormScreen extends StatefulWidget {
  const DataDiriFormScreen({super.key, this.existing});

  /// Data yang sudah ada untuk mode edit (null = mode tambah)
  final DataDiri? existing;

  @override
  State<DataDiriFormScreen> createState() => _DataDiriFormScreenState();
}

class _DataDiriFormScreenState extends State<DataDiriFormScreen> {
  // FR-01: Form key
  final _formKey = GlobalKey<FormState>();

  // FR-01: Controller untuk setiap field
  late final TextEditingController _deskripsiController;
  late final TextEditingController _kontakController;
  late final TextEditingController _programStudiController;
  late final TextEditingController _fakultasController;
  late final TextEditingController _ipkController;

  bool _isSaving = false;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    // FR-01: Pre-fill controller jika mode edit
    final ex = widget.existing;
    _deskripsiController =
        TextEditingController(text: ex?.deskripsiSingkat ?? '');
    _kontakController = TextEditingController(text: ex?.kontak ?? '');
    _programStudiController =
        TextEditingController(text: ex?.programStudi ?? '');
    _fakultasController = TextEditingController(text: ex?.fakultas ?? '');
    _ipkController = TextEditingController(
      text: ex != null ? ex.ipk.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    // FR-01: Dispose semua controller
    _deskripsiController.dispose();
    _kontakController.dispose();
    _programStudiController.dispose();
    _fakultasController.dispose();
    _ipkController.dispose();
    super.dispose();
  }

  // FR-01: Simpan — validasi → create/update → pop dengan hasil
  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<AppProvider>();
      final ipk = double.parse(_ipkController.text.trim());

      final DataDiri dataDiri;

      if (_isEditMode) {
        // FR-01: Update
        final updated = widget.existing!.copyWith(
          deskripsiSingkat: _deskripsiController.text.trim(),
          kontak: _kontakController.text.trim(),
          programStudi: _programStudiController.text.trim(),
          fakultas: _fakultasController.text.trim(),
          ipk: ipk,
        );
        dataDiri = await provider.dataDiriRepository.updateDataDiri(updated);
      } else {
        // FR-01: Create
        final baru = DataDiri(
          idPengguna: provider.idPengguna,
          deskripsiSingkat: _deskripsiController.text.trim(),
          kontak: _kontakController.text.trim(),
          programStudi: _programStudiController.text.trim(),
          fakultas: _fakultasController.text.trim(),
          ipk: ipk,
        );
        dataDiri = await provider.dataDiriRepository.saveDataDiri(baru);
      }

      if (!mounted) return;

      // FR-01: Kembalikan DataDiri ke DataDiriScreen
      Navigator.pop(context, dataDiri);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Data Diri' : 'Tambah Data Diri',
          style: AppTextStyles.title,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FR-01: Field deskripsi singkat
              _FormField(
                label: 'Deskripsi Singkat',
                icon: Icons.description_outlined,
                child: TextFormField(
                  controller: _deskripsiController,
                  minLines: 3,
                  maxLines: 5,
                  validator: (v) =>
                      Validators.requiredField(v, 'Deskripsi Singkat'),
                  style: AppTextStyles.body,
                  decoration: _inputDecoration(
                    'Ceritakan tentang diri Anda...',
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // FR-01: Field kontak
              _FormField(
                label: 'Kontak',
                icon: Icons.phone_outlined,
                child: TextFormField(
                  controller: _kontakController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.requiredField(v, 'Kontak'),
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('Nomor HP atau email...'),
                ),
              ),
              const SizedBox(height: 14),

              // FR-01: Field program studi
              _FormField(
                label: 'Program Studi',
                icon: Icons.school_outlined,
                child: TextFormField(
                  controller: _programStudiController,
                  validator: (v) =>
                      Validators.requiredField(v, 'Program Studi'),
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('Contoh: Sistem Informasi'),
                ),
              ),
              const SizedBox(height: 14),

              // FR-01: Field fakultas
              _FormField(
                label: 'Fakultas',
                icon: Icons.account_balance_outlined,
                child: TextFormField(
                  controller: _fakultasController,
                  validator: (v) => Validators.requiredField(v, 'Fakultas'),
                  style: AppTextStyles.body,
                  decoration:
                      _inputDecoration('Contoh: Teknologi Informasi'),
                ),
              ),
              const SizedBox(height: 14),

              // FR-01: Field IPK (numerik, rentang 0.00–4.00)
              _FormField(
                label: 'IPK',
                icon: Icons.grade_outlined,
                child: TextFormField(
                  controller: _ipkController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: Validators.ipk,
                  style: AppTextStyles.body,
                  decoration: _inputDecoration('Contoh: 3.71'),
                ),
              ),
              const SizedBox(height: 28),

              // FR-01: Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _simpan,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mutedText,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedText),
        filled: true,
        fillColor: Colors.white,
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
          borderSide:
              const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      );
}

// Widget wrapper label + icon untuk setiap field
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primaryDark),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
