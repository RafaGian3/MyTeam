import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

/// Halaman Masuk / Login Akun Mahasiswa
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimCtrl = TextEditingController(text: '2411522001'); // Default akun Fuadi
  final _passCtrl = TextEditingController(text: 'SandiAman123!');
  final _viewModel = AuthViewModel();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nimCtrl.dispose();
    _passCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.login(
      _nimCtrl.text.trim(),
      _passCtrl.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Login gagal'),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Brand
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryOutline),
                      ),
                      child: Image.asset(
                        'assets/images/logo-MyTeam.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.groups_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Selamat Datang di MyTeam',
                      style: AppTextStyles.headlineMd.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Pencarian dan Pembentukan Tim Mahasiswa Unand',
                      style: AppTextStyles.bodySm,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Form Input
                  AuthTextField(
                    label: 'NIM Mahasiswa',
                    hint: 'Masukkan NIM Anda',
                    controller: _nimCtrl,
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.validateNim,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),

                  AuthTextField(
                    label: 'Kata Sandi',
                    hint: 'Masukkan kata sandi',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePass,
                    onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                    validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                  ),
                  const SizedBox(height: 28),

                  // Tombol Masuk
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _viewModel.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _viewModel.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Masuk Sekarang',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Link Daftar Akun
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum memiliki akun? ', style: AppTextStyles.bodySm),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Text(
                          'Daftar di sini',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
