import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

/// Halaman Registrasi Akun Mahasiswa Unand
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _viewModel = AuthViewModel();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nimCtrl.dispose();
    _namaCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok!'), backgroundColor: AppColors.statusDangerText),
      );
      return;
    }

    final success = await _viewModel.register(
      nim: _nimCtrl.text.trim(),
      namaPengguna: _namaCtrl.text.trim(),
      kataSandi: _passCtrl.text,
      kataSandiKonfirmasi: _confirmPassCtrl.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Selamat datang di MyTeam.'), backgroundColor: AppColors.primaryContainer),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage ?? 'Registrasi gagal'), backgroundColor: AppColors.statusDangerText),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bergabung dengan MyTeam', style: AppTextStyles.headlineMd),
                const SizedBox(height: 6),
                Text('Daftar menggunakan NIM aktif Universitas Andalas', style: AppTextStyles.bodySm),
                const SizedBox(height: 24),

                AuthTextField(
                  label: 'NIM Mahasiswa',
                  hint: 'Contoh: 2411522001',
                  controller: _nimCtrl,
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.validateNim,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkap Anda',
                  controller: _namaCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => Validators.validateRequired(v, 'Nama lengkap'),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  controller: _passCtrl,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePass,
                  onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) => (v == null || v.length < 6) ? 'Kata sandi minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi Anda',
                  controller: _confirmPassCtrl,
                  prefixIcon: Icons.lock_clock_outlined,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) => (v == null || v.isEmpty) ? 'Konfirmasi kata sandi wajib diisi' : null,
                ),
                const SizedBox(height: 28),

                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _viewModel.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Daftar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
