import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/data_diri.dart';
import '../../providers/app_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/state_views.dart';

// FR-01: Screen untuk menampilkan, mengedit, dan menghapus data diri pengguna
class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // FR-01: Muat data diri saat screen pertama kali dibuka
    _loadDataDiri();
  }

  // FR-01: Muat data diri dari repository
  Future<void> _loadDataDiri() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<AppProvider>();
      final data = await provider.dataDiriRepository
          .getDataDiri(provider.idPengguna);

      if (!mounted) return;

      provider.setDataDiri(data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // FR-01: Buka form tambah/edit data diri
  Future<void> _bukaForm({DataDiri? existing}) async {
    final hasil = await Navigator.pushNamed<DataDiri>(
      context,
      AppRoutes.dataDiriForm,
      arguments: existing,
    );

    if (!mounted || hasil == null) return;

    context.read<AppProvider>().setDataDiri(hasil);
  }

  // FR-01: Konfirmasi dan hapus data diri
  Future<void> _hapus() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Diri?'),
        content: const Text(
          'Data diri yang tersimpan akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<AppProvider>();
      await provider.dataDiriRepository.deleteDataDiri(provider.idPengguna);

      if (!mounted) return;

      provider.clearDataDiri();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data diri berhasil dihapus.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // FR-01: Konfirmasi logout dan kembali ke login
  Future<void> _keluar() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari MyTeam?'),
        content: const Text('Sesi Anda akan diakhiri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    context.read<AppProvider>().logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final dataDiri = context.watch<AppProvider>().dataDiri;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Diri', style: AppTextStyles.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          // Tombol Keluar
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _keluar,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingView(message: 'Memuat data diri...')
          : _errorMessage != null
              ? ErrorView(
                  message: _errorMessage!,
                  onRetry: _loadDataDiri,
                )
              : dataDiri == null
                  // FR-01: Kondisi A — data belum tersedia
                  ? _EmptyDataDiri(onTambah: () => _bukaForm())
                  // FR-01: Kondisi B — data tersedia
                  : _DataDiriContent(
                      dataDiri: dataDiri,
                      onEdit: () => _bukaForm(existing: dataDiri),
                      onHapus: _hapus,
                    ),
    );
  }
}

// FR-01: Widget kondisi kosong
class _EmptyDataDiri extends StatelessWidget {
  const _EmptyDataDiri({required this.onTambah});
  final VoidCallback onTambah;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 52,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data diri belum tersedia',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Lengkapi data diri Anda agar profil terlihat lebih menarik oleh recruiter tim.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onTambah,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambahkan Data Diri'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FR-01: Widget menampilkan data diri yang tersedia
class _DataDiriContent extends StatelessWidget {
  const _DataDiriContent({
    required this.dataDiri,
    required this.onEdit,
    required this.onHapus,
  });

  final DataDiri dataDiri;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataDiri.programStudi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dataDiri.fakultas,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'IPK ${dataDiri.ipk.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detail fields
          _FieldCard(
            icon: Icons.description_outlined,
            label: 'Deskripsi Singkat',
            value: dataDiri.deskripsiSingkat,
          ),
          const SizedBox(height: 10),
          _FieldCard(
            icon: Icons.phone_outlined,
            label: 'Kontak',
            value: dataDiri.kontak,
          ),
          const SizedBox(height: 10),
          _FieldCard(
            icon: Icons.school_outlined,
            label: 'Program Studi',
            value: dataDiri.programStudi,
          ),
          const SizedBox(height: 10),
          _FieldCard(
            icon: Icons.account_balance_outlined,
            label: 'Fakultas',
            value: dataDiri.fakultas,
          ),
          const SizedBox(height: 10),
          _FieldCard(
            icon: Icons.grade_outlined,
            label: 'IPK',
            value: dataDiri.ipk.toStringAsFixed(2),
          ),
          const SizedBox(height: 24),

          // Tombol aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onHapus,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Widget kartu field data diri
class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 3),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
