import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width > 500 ? 48 : 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const AppLogo(size: 72),
                  const SizedBox(height: 44),
                  Text('Selamat Datang di MyTeam', style: AppTextStyles.heading.copyWith(fontSize: 23), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Platform Kolaborasi & Pencarian Rekan Tim\nMahasiswa Universitas Andalas', style: AppTextStyles.body.copyWith(color: AppColors.mutedText), textAlign: TextAlign.center),
                  const SizedBox(height: 26),
                  _AuthModeSwitch(isLogin: provider.isLoginMode, onChanged: provider.toggleAuthMode),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!provider.isLoginMode) ...[
                          const AuthField(label: 'Nama Lengkap', hintText: 'Masukkan nama lengkap', icon: Icons.person_outline_rounded),
                          const SizedBox(height: 16),
                        ],
                        const AuthField(
                          label: 'NIM atau Email Kampus',
                          hintText: '2111522000 / nama@student...',
                          icon: Icons.alternate_email_rounded,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                '@student.unand.ac.id',
                                style: TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthField(label: 'Kata Sandi', hintText: '••••••••••••', icon: Icons.lock_outline_rounded, controller: _passwordController, obscureText: !provider.isPasswordVisible, suffixIcon: IconButton(onPressed: provider.togglePasswordVisibility, icon: Icon(provider.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.mutedText))),
                        if (provider.isLoginMode) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Lupa Kata Sandi?', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)))),
                        const SizedBox(height: 4),
                        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: widget.onAuthenticated, icon: Icon(provider.isLoginMode ? Icons.login_rounded : Icons.person_add_alt_1_rounded), label: Text(provider.isLoginMode ? 'Masuk ke MyTeam  →' : 'Daftar ke MyTeam'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontWeight: FontWeight.w700)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _DividerLabel(label: 'ATAU AKSES CEPAT'),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(onPressed: widget.onAuthenticated, icon: const Icon(Icons.domain, color: AppColors.primaryDark), label: const Text('Masuk dengan Akun Portal Unand', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide.none, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 22),
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.groups_rounded, color: AppColors.primaryDark)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('340+ Proyek Aktif', style: AppTextStyles.label), const SizedBox(height: 3), Text('Temukan teman satu visi dari lintas fakultas', style: AppTextStyles.caption)])), const _TinyBadge(label: 'PKM & Lomba')])),
                  const SizedBox(height: 28),
                  Text('Universitas Andalas  •  Bantuan IT', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Lembaga Pengembangan Pendidikan dan Penjaminan Mutu\n(LP3M)', style: AppTextStyles.caption, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.isLogin, required this.onChanged});
  final bool isLogin;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.lavenderStrong, borderRadius: BorderRadius.circular(30)), child: Row(children: [Expanded(child: _ModeButton(label: '↪  Masuk', active: isLogin, onPressed: () => onChanged(true))), Expanded(child: _ModeButton(label: '♙  Daftar', active: !isLogin, onPressed: () => onChanged(false)))]));
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.active, required this.onPressed});
  final String label;
  final bool active;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => TextButton(onPressed: onPressed, style: TextButton.styleFrom(backgroundColor: active ? AppColors.primaryDark : Colors.transparent, foregroundColor: active ? Colors.white : AppColors.mutedText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 11)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)));
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [const Expanded(child: Divider(color: AppColors.border)), Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w700))), const Expanded(child: Divider(color: AppColors.border))]);
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(9)), child: Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w700)));
}
