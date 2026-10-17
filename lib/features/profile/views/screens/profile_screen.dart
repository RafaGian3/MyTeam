import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/views/widgets/logout_confirmation_sheet.dart';
import '../../models/data_diri_model.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/edit_data_diri_dialog.dart';
import '../widgets/form_keahlian_dialog.dart';
import '../widgets/form_minat_dialog.dart';
import '../widgets/form_pengalaman_dialog.dart';
import '../widgets/form_medsos_dialog.dart';
import '../widgets/profile_skeleton.dart';
import '../../models/tim_diikuti_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Layar Profil Mahasiswa — MyTeam (Modul 1: FR-01 s/d FR-07)
/// Mengimplementasikan arsitektur MVVM murni dengan ProfileViewModel
class ProfileScreen extends StatefulWidget {
  final String? idPenggunaOverride;

  const ProfileScreen({super.key, this.idPenggunaOverride});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _viewModel = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.loadProfile(idPenggunaOverride: widget.idPenggunaOverride);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        automaticallyImplyLeading: false,
        leading: widget.idPenggunaOverride != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Kembali',
                    ),
                  ),
                ),
              )
            : null,
        titleSpacing: widget.idPenggunaOverride != null ? 0 : 20,
        title: widget.idPenggunaOverride != null
            ? Text(
                'Profil Mahasiswa',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              )
            : Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo-MyTeam.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MyTeam',
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Profil & Portofolio Mahasiswa',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
              onPressed: () => _viewModel.loadProfile(idPenggunaOverride: widget.idPenggunaOverride),
              tooltip: 'Segarkan Profil',
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final profile = _viewModel.profile;

          // 1. Loading awal tanpa data sebelumnya: Tampilkan Skeleton Screen terstruktur
          if (_viewModel.isLoading && profile == null) {
            return const ProfileSkeleton();
          }

          // 2. Error tanpa data di memori
          if (_viewModel.errorMessage != null && profile == null) {
            return _buildErrorView();
          }

          // 3. Fallback jika data belum tersedia
          if (profile == null) {
            return const ProfileSkeleton();
          }

          // 4. Data siap: Ditampilkan instan tanpa loading berputar!
          return RefreshIndicator(
            onRefresh: () => _viewModel.loadProfile(idPenggunaOverride: widget.idPenggunaOverride),
            color: AppColors.primaryContainer,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: ProfileHeaderCard(
                    user: profile.pengguna,
                    onGantiFoto: _showGantiFotoDialog,
                    onSettings: widget.idPenggunaOverride == null ? _showSettingsSheet : null,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(_tabController),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildTentangTab(),
                  _buildMinatTab(),
                  _buildKeahlianTab(),
                  _buildPengalamanTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.statusDangerText, size: 56),
            const SizedBox(height: 16),
            Text('Gagal Memuat Profil', style: AppTextStyles.titleMd),
            const SizedBox(height: 8),
            Text(_viewModel.errorMessage ?? 'Terjadi kesalahan.', style: AppTextStyles.bodySm, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _viewModel.loadProfile(idPenggunaOverride: widget.idPenggunaOverride),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: TENTANG & MEDSOS ──────────────────────────────────────────────
  Widget _buildTentangTab() {
    final profile = _viewModel.profile!;
    final dataDiri = profile.dataDiri;
    final medsosList = profile.mediaSosial;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          title: 'Tentang Saya',
          icon: Icons.person_outline_rounded,
          action: widget.idPenggunaOverride == null
              ? TextButton.icon(
                  onPressed: () => EditDataDiriDialog.show(
                    context,
                    dataDiri: dataDiri,
                    onSave: _viewModel.updateDataDiri,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: Text('Edit', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                )
              : null,
          child: Text(
            (dataDiri?.deskripsiSingkat != null && dataDiri!.deskripsiSingkat.trim().isNotEmpty)
                ? dataDiri.deskripsiSingkat
                : 'Belum ada deskripsi singkat. Tambahkan bio agar calon rekan tim dapat mengenal Anda lebih dekat.',
            style: AppTextStyles.bodyMd.copyWith(
              color: (dataDiri?.deskripsiSingkat != null && dataDiri!.deskripsiSingkat.trim().isNotEmpty)
                  ? AppColors.text
                  : AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildAkademikCard(dataDiri),
        const SizedBox(height: 16),

        _buildSectionCard(
          title: 'Kontak',
          icon: Icons.phone_outlined,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: (dataDiri?.kontak != null && dataDiri!.kontak.trim().isNotEmpty)
                  ? () => _openWhatsApp(dataDiri.kontak)
                  : () {
                      if (widget.idPenggunaOverride == null) {
                        EditDataDiriDialog.show(
                          context,
                          dataDiri: dataDiri,
                          onSave: _viewModel.updateDataDiri,
                        );
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.statusSuccessBg, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.statusSuccessText, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nomor Kontak / WhatsApp', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            (dataDiri?.kontak != null && dataDiri!.kontak.isNotEmpty) ? dataDiri.kontak : 'Belum diisi',
                            style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    if (dataDiri?.kontak != null && dataDiri!.kontak.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccessBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.statusSuccessText),
                            const SizedBox(width: 4),
                            Text(
                              'Buka WA',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.statusSuccessText,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          title: 'Media Sosial',
          icon: Icons.link_rounded,
          action: widget.idPenggunaOverride == null
              ? TextButton.icon(
                  onPressed: () => FormMedsosDialog.show(context, onSave: _viewModel.addMediaSosial),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tambah', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                )
              : null,
          child: medsosList.isEmpty
              ? _buildEmptyState('Belum ada media sosial ditambahkan.')
              : Column(
                  children: medsosList.map((m) {
                    final isOwner = widget.idPenggunaOverride == null;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _openUrl(m.linkMediaSosial),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.public_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.namaMediaSosial, style: AppTextStyles.titleMd.copyWith(fontSize: 13)),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              m.linkMediaSosial,
                                              style: AppTextStyles.bodySm.copyWith(color: AppColors.primary, fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.open_in_new_rounded, size: 11, color: AppColors.primary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwner) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                                    onPressed: () => FormMedsosDialog.show(
                                      context,
                                      item: m,
                                      onSave: (nama, link) => _viewModel.updateMediaSosial(m.idMediaSosial, nama, link),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.statusDangerText),
                                    onPressed: () => _konfirmasiHapus(
                                      judul: 'Hapus Media Sosial',
                                      pesan: 'Apakah Anda yakin ingin menghapus akun "${m.namaMediaSosial}" dari profil?',
                                      onConfirm: () => _viewModel.deleteMediaSosial(m.idMediaSosial),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        _buildTimDiikutiCard(profile.timDiikuti),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _konfirmasiHapus({
    required String judul,
    required String pesan,
    required Future<bool> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusDangerBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDangerText, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                judul,
                style: AppTextStyles.titleMd.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          pesan,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.text, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusDangerText,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await onConfirm();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$judul berhasil dihapus.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String urlString) async {
    try {
      String formattedUrl = urlString.trim();
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final uri = Uri.parse(formattedUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka tautan: $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isChannelError = e.toString().contains('channel-error') || e.toString().contains('UrlLauncherApi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChannelError
                  ? 'Harap restart aplikasi (hentikan lalu jalankan kembali flutter run) agar plugin browser/WA terpasang.'
                  : 'Gagal membuka tautan: $e',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String? rawPhone) async {
    if (rawPhone == null || rawPhone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kontak belum diisi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }

    final waUrl = 'https://wa.me/$phone';
    await _openUrl(waUrl);
  }

  // ─── TAB 2: MINAT (FR-04) ─────────────────────────────────────────────────
  Widget _buildMinatTab() {
    final profile = _viewModel.profile!;
    final minatList = profile.minat;
    final isOwner = widget.idPenggunaOverride == null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          title: 'Minat',
          icon: Icons.interests_rounded,
          action: isOwner
              ? TextButton.icon(
                  onPressed: () => FormMinatDialog.show(context, onSave: _viewModel.addMinat),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tambah', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                )
              : null,
          child: minatList.isEmpty
              ? _buildEmptyState('Belum ada minat bidang ditambahkan.')
              : Column(
                  children: minatList.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.minat, style: AppTextStyles.titleMd.copyWith(fontSize: 14)),
                                if (m.deskripsiMinat.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(m.deskripsiMinat, style: AppTextStyles.bodySm),
                                ],
                              ],
                            ),
                          ),
                          if (isOwner) ...[
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                              onPressed: () => FormMinatDialog.show(
                                context,
                                item: m,
                                onSave: (nama, desc) => _viewModel.updateMinat(m.idMinat, nama, desc),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.statusDangerText),
                              onPressed: () => _konfirmasiHapus(
                                judul: 'Hapus Minat',
                                pesan: 'Apakah Anda yakin ingin menghapus bidang minat "${m.minat}"?',
                                onConfirm: () => _viewModel.deleteMinat(m.idMinat),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ─── TAB 3: KEAHLIAN (FR-03) ──────────────────────────────────────────────
  Widget _buildKeahlianTab() {
    final profile = _viewModel.profile!;
    final keahlianList = profile.keahlian;
    final isOwner = widget.idPenggunaOverride == null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          title: 'Keahlian',
          icon: Icons.auto_awesome_rounded,
          action: isOwner
              ? TextButton.icon(
                  onPressed: () => FormKeahlianDialog.show(context, onSave: _viewModel.addKeahlian),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tambah', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                )
              : null,
          child: keahlianList.isEmpty
              ? _buildEmptyState('Belum ada keahlian ditambahkan.')
              : Column(
                  children: keahlianList.map((k) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.keahlian, style: AppTextStyles.titleMd.copyWith(fontSize: 14)),
                                if (k.deskripsiKeahlian.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(k.deskripsiKeahlian, style: AppTextStyles.bodySm),
                                ],
                              ],
                            ),
                          ),
                          if (isOwner) ...[
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                              onPressed: () => FormKeahlianDialog.show(
                                context,
                                item: k,
                                onSave: (nama, desc) => _viewModel.updateKeahlian(k.idKeahlian, nama, desc),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.statusDangerText),
                              onPressed: () => _konfirmasiHapus(
                                judul: 'Hapus Keahlian',
                                pesan: 'Apakah Anda yakin ingin menghapus keahlian "${k.keahlian}"?',
                                onConfirm: () => _viewModel.deleteKeahlian(k.idKeahlian),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ─── TAB 4: PENGALAMAN (FR-05) ────────────────────────────────────────────
  Widget _buildPengalamanTab() {
    final pengalamanList = _viewModel.profile!.pengalaman;
    final isOwner = widget.idPenggunaOverride == null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          title: 'Pengalaman',
          icon: Icons.workspace_premium_rounded,
          action: isOwner
              ? TextButton.icon(
                  onPressed: () => FormPengalamanDialog.show(
                    context,
                    onSave: ({required namaKegiatan, required peran, required tahun, required deskripsi}) =>
                        _viewModel.addPengalaman(namaKegiatan, peran, tahun, deskripsi),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tambah', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                )
              : null,
          child: pengalamanList.isEmpty
              ? _buildEmptyState('Belum ada riwayat kegiatan/pengalaman.')
              : Column(
                  children: pengalamanList.map((p) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.namaKegiatan,
                                      style: AppTextStyles.titleMd.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Peran: ${p.peran}',
                                      style: AppTextStyles.labelMd.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tahun ${p.tahun}',
                                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isOwner) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                                  onPressed: () => FormPengalamanDialog.show(
                                    context,
                                    item: p,
                                    onSave: ({required namaKegiatan, required peran, required tahun, required deskripsi}) =>
                                        _viewModel.updatePengalaman(p.idPengalaman, namaKegiatan, peran, tahun, deskripsi),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.statusDangerText),
                                  onPressed: () => _konfirmasiHapus(
                                    judul: 'Hapus Pengalaman',
                                    pesan: 'Apakah Anda yakin ingin menghapus kegiatan "${p.namaKegiatan}"?',
                                    onConfirm: () => _viewModel.deletePengalaman(p.idPengalaman),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          Text(p.deskripsiPengalaman, style: AppTextStyles.bodySm.copyWith(color: AppColors.text, height: 1.45)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ─── TIM YANG DIIKUTI CARD (FR-06 - Ditampilkan di Tab Tentang) ───────────
  Widget _buildTimDiikutiCard(List<TimDiikutiModel> timList) {
    return _buildSectionCard(
      title: 'Tim yang Diikuti',
      icon: Icons.groups_rounded,
      child: timList.isEmpty
          ? _buildEmptyState('Mahasiswa belum tergabung dalam tim manapun.')
          : Column(
              children: timList.map((t) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.group_work_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(t.namaTim, style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.categoryCompetitionBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    t.kategoriKegiatan,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.categoryCompetitionText,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Kegiatan: ${t.namaKegiatan}', style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text('Posisi: ${t.posisi}', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _showSettingsSheet() {
    final profile = _viewModel.profile;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengaturan & Kelola Profil',
                              style: AppTextStyles.titleMd.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pusat kendali akun & modul portofolio',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Scrollable List
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GROUP 1: BIODATA & DATA DIRI
                      _buildSettingsSectionHeader('DATA DIRI & PROFIL'),
                      _buildSettingsTile(
                        icon: Icons.camera_alt_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        title: 'Perbarui Foto Profil',
                        subtitle: 'Ganti avatar atau unggah foto profil baru',
                        onTap: () {
                          Navigator.pop(ctx);
                          _showGantiFotoDialog();
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFF00796B),
                        iconBg: const Color(0xFFE0F2F1),
                        title: 'Edit Biodata & Kontak',
                        subtitle: 'Perbarui data akademik, bio, dan nomor WhatsApp',
                        onTap: () {
                          Navigator.pop(ctx);
                          EditDataDiriDialog.show(
                            context,
                            dataDiri: profile?.dataDiri,
                            onSave: _viewModel.updateDataDiri,
                          );
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.share_outlined,
                        iconColor: const Color(0xFF7B1FA2),
                        iconBg: const Color(0xFFF3E5F5),
                        title: 'Kelola Media Sosial',
                        subtitle: 'Tautkan LinkedIn, GitHub, Instagram, & portofolio',
                        onTap: () {
                          Navigator.pop(ctx);
                          _tabController.animateTo(0);
                          FormMedsosDialog.show(
                            context,
                            onSave: _viewModel.addMediaSosial,
                          );
                        },
                      ),

                      const SizedBox(height: 8),
                      // GROUP 2: KOMPETENSI & REKAM JEJAK
                      _buildSettingsSectionHeader('KOMPETENSI & REKAM JEJAK'),
                      _buildSettingsTile(
                        icon: Icons.interests_rounded,
                        iconColor: const Color(0xFFE65100),
                        iconBg: const Color(0xFFFFF3E0),
                        title: 'Kelola Minat Bidang',
                        subtitle: 'Buka tab minat untuk kelola topik ketertarikan',
                        trailingBadge: 'Tab Minat',
                        onTap: () {
                          Navigator.pop(ctx);
                          _tabController.animateTo(1);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.psychology_outlined,
                        iconColor: const Color(0xFF1565C0),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'Kelola Keahlian Teknis',
                        subtitle: 'Buka tab keahlian untuk kelola skill & level kemahiran',
                        trailingBadge: 'Tab Keahlian',
                        onTap: () {
                          Navigator.pop(ctx);
                          _tabController.animateTo(2);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        iconColor: const Color(0xFF2E7D32),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'Kelola Riwayat Pengalaman',
                        subtitle: 'Buka tab pengalaman untuk kelola organisasi & lomba',
                        trailingBadge: 'Tab Pengalaman',
                        onTap: () {
                          Navigator.pop(ctx);
                          _tabController.animateTo(3);
                        },
                      ),

                      const SizedBox(height: 8),
                      // GROUP 3: APLIKASI & AKUN
                      _buildSettingsSectionHeader('APLIKASI & AKUN'),
                      _buildSettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFF455A64),
                        iconBg: const Color(0xFFECEFF1),
                        title: 'Tentang Aplikasi MyTeam',
                        subtitle: 'MyTeam Mobile v1.0.1 • Universitas Andalas',
                        onTap: () {
                          Navigator.pop(ctx);
                          _showTentangAplikasiDialog();
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.statusDangerText,
                        iconBg: AppColors.statusDangerBg,
                        title: 'Keluar dari Akun',
                        subtitle: 'Akhiri sesi aplikasi MyTeam pada perangkat ini',
                        isDestructive: true,
                        onTap: () {
                          Navigator.pop(ctx);
                          LogoutConfirmationSheet.show(
                            context,
                            nama: profile?.pengguna.namaPengguna,
                            nim: profile?.pengguna.nim,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingBadge,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDestructive ? AppColors.statusDangerBg.withValues(alpha: 0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.statusDangerText : AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailingBadge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingBadge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textMuted),
                  ],
                ),
              )
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  void _showTentangAplikasiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'MyTeam Mobile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'v1.0.1 • Modul 1 Akun & Profil',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Aplikasi kolaborasi dan pencarian talenta mahasiswa untuk pembentukan tim kompetisi, riset, dan proyek di Universitas Andalas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.school_outlined, size: 16, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Universitas Andalas • Padang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tutup',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGantiFotoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Perbarui Foto Profil', style: AppTextStyles.titleMd.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          'Pilih berkas foto atau gunakan avatar mahasiswa',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Opsi Unggah Berkas Baru (Galeri & Kamera)
              Text('Unggah dari Perangkat', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoActionTile(
                      ctx,
                      icon: Icons.photo_library_outlined,
                      label: 'Buka Galeri',
                      subtitle: 'JPG / PNG / WebP',
                      onTap: () => _pickAndUploadPhoto(ctx, ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPhotoActionTile(
                      ctx,
                      icon: Icons.camera_alt_outlined,
                      label: 'Ambil Foto',
                      subtitle: 'Kamera langsung',
                      onTap: () => _pickAndUploadPhoto(ctx, ImageSource.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ATAU PILIH AVATAR MAHASISWA', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 16),

              // 2 Avatar Mahasiswa (Cowok & Cewek)
              Row(
                children: [
                  Expanded(
                    child: _buildPresetAvatarTile(
                      ctx,
                      assetPath: 'assets/images/avatar_male.jpg',
                      nama: 'Mahasiswa',
                      label: 'Jas Almamater',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPresetAvatarTile(
                      ctx,
                      assetPath: 'assets/images/avatar_female.jpg',
                      nama: 'Mahasiswi',
                      label: 'Jas Almamater',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext modalCtx, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(modalCtx);
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      nav.pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 12),
              Text('Mengunggah foto profil...'),
            ],
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final success = await _viewModel.uploadFotoProfilFile(pickedFile.path);
      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Gagal mengunggah foto profil.'),
            backgroundColor: AppColors.statusDangerText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Akses berkas ditolak atau terjadi kendala: ${e.toString()}'),
          backgroundColor: AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPhotoActionTile(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label, style: AppTextStyles.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetAvatarTile(
    BuildContext ctx, {
    required String assetPath,
    required String nama,
    required String label,
  }) {
    return InkWell(
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(ctx);
        final success = await _viewModel.updateFotoProfil(assetPath);
        if (mounted && success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Avatar $nama berhasil diterapkan!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(assetPath),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nama,
              style: AppTextStyles.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAkademikCard(DataDiriModel? dataDiri) {
    final prodi = (dataDiri?.programStudi != null && dataDiri!.programStudi.isNotEmpty)
        ? dataDiri.programStudi
        : 'Sistem Informasi';
    final fakultas = (dataDiri?.fakultas != null && dataDiri!.fakultas.isNotEmpty)
        ? dataDiri.fakultas
        : 'Teknologi Informasi';
    final ipk = (dataDiri?.ipk ?? 0.00).toStringAsFixed(2);

    return _buildSectionCard(
      title: 'Akademik',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          _buildAkademikRow(Icons.school_outlined, 'Program Studi', prodi),
          const Divider(height: 16, color: AppColors.border),
          _buildAkademikRow(Icons.account_balance_outlined, 'Fakultas', fakultas),
          const Divider(height: 16, color: AppColors.border),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.categoryCompetitionBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars_rounded, color: AppColors.categoryCompetitionText, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Indeks Prestasi Kumulatif', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 1),
                    Text('IPK: $ipk', style: AppTextStyles.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAkademikRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 1),
              Text(value, style: AppTextStyles.titleMd.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, Widget? action, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyles.titleMd.copyWith(fontSize: 16, fontWeight: FontWeight.w700))),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(msg, style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic, color: AppColors.textMuted)),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;

  _SliverTabBarDelegate(this.controller);

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            _buildTabItem(0, Icons.person_rounded, 'Tentang'),
            _buildTabItem(1, Icons.interests_rounded, 'Minat'),
            _buildTabItem(2, Icons.auto_awesome_rounded, 'Keahlian'),
            _buildTabItem(3, Icons.workspace_premium_rounded, 'Pengalaman'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = controller.index == index;
    return Expanded(
      flex: isSelected ? 4 : 2,
      child: GestureDetector(
        onTap: () => controller.animateTo(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => true;
}
