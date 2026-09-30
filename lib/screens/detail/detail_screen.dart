import 'package:flutter/material.dart';

import '../../models/tim.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.tim});

  /// Data tim yang dikirim dari HomeScreen via Navigator.pushNamed arguments
  final Tim tim;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan catatan yang dikembalikan dari CatatanFormScreen
  String? _catatan;

  /// Buka CatatanFormScreen dan tunggu hasilnya.
  /// `Navigator.pushNamed` dengan tipe String berarti screen tersebut akan mengembalikan String.
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    // Guard: pastikan widget masih terpasang sebelum setState
    if (!mounted || hasil == null) return;
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Akses data tim melalui widget.tim (karena ini StatefulWidget)
    final tim = widget.tim;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tim.namaTim, style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header kartu ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tim.statusTim.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(tim.namaTim, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(tim.kategoriKegiatan, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Informasi tim ────────────────────────────────────────────────
            _InfoRow(label: 'Nama Kegiatan', value: tim.namaKegiatan),
            const SizedBox(height: 12),
            _InfoRow(label: 'Kategori', value: tim.kategoriKegiatan),
            const SizedBox(height: 12),
            _InfoRow(label: 'Status', value: tim.statusTim),
            const SizedBox(height: 20),

            // ── Deskripsi ────────────────────────────────────────────────────
            Text('Deskripsi', style: AppTextStyles.label),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(tim.deskripsi, style: AppTextStyles.body),
            ),
            const SizedBox(height: 20),

            // ── Catatan ──────────────────────────────────────────────────────
            Text('Catatan', style: AppTextStyles.label),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              // Tampilkan catatan jika ada, atau teks placeholder
              child: Text(
                _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
                style: AppTextStyles.body.copyWith(
                  color: _catatan == null ? AppColors.mutedText : AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol Tulis Catatan ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _bukaFormCatatan,
                icon: const Icon(Icons.edit_note),
                label: const Text('Tulis Catatan'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget baris informasi label + value
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyles.label),
        ),
        const Text(': '),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ],
    );
  }
}
