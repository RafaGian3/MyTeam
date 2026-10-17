import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/team_model.dart';
import '../../services/team_draft_service.dart';
import '../../viewmodels/team_management_viewmodel.dart';
import '../widgets/team_card.dart';
import '../widgets/team_drafts_modal.dart';
import '../widgets/team_management_edit_modal.dart';
import 'team_management_create_screen.dart';
import 'team_management_detail_screen.dart';

/// Halaman Daftar Tim Saya — FR-09 & FR-11
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final _vm = TeamManagementViewModel();
  List<TeamDraftModel> _savedDrafts = [];

  @override
  void initState() {
    super.initState();
    _checkDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vm.loadMyTeams();
      }
    });
  }

  Future<void> _checkDraft() async {
    final drafts = await TeamDraftService.getAllDrafts();
    if (mounted) {
      setState(() => _savedDrafts = drafts);
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String idTim, String namaTim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Tim?', style: AppTextStyles.headlineMd),
        content: Text(
          'Tim "$namaTim" beserta seluruh data terkaitnya akan dihapus secara permanen.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          // Batal (50%)
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Text(
                'Batal',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Hapus (50%)
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusDangerText,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _vm.deleteTeam(idTim);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Tim berhasil dihapus.'
                  : (_vm.saveError ?? 'Gagal menghapus tim.'),
            ),
            backgroundColor: success
                ? AppColors.statusSuccessText
                : AppColors.statusDangerText,
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
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoadingList) return _buildLoading();
          if (_vm.listError != null) return _buildError(_vm.listError!);
          return Column(
            children: [
              _buildDraftBannerCard(),
              Expanded(
                child: _vm.myTeams.isEmpty ? _buildEmpty() : _buildTeamList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo MyTeam (DESIGN.md §3.6.1)
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryOutline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo-MyTeam.png',
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.groups_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MyTeam',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              Text('Tim Saya', style: AppTextStyles.bodySm),
            ],
          ),
        ],
      ),
      actions: [
        // Tombol Refresh (DESIGN.md §3.6.1)
        GestureDetector(
          onTap: _vm.loadMyTeams,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: AppTextStyles.titleMd),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _vm.loadMyTeams,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo redup sebagai empty state (DESIGN.md §1.1)
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/logo-MyTeam.png',
                width: 96,
                height: 96,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.groups_outlined,
                  size: 80,
                  color: AppColors.primaryOutline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Belum Ada Tim', style: AppTextStyles.headlineMd),
            const SizedBox(height: 8),
            Text(
              'Buat tim pertamamu untuk\nmencari anggota yang sesuai.',
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreate(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Buat Tim Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildDraftBannerCard() {
    if (_savedDrafts.isEmpty) return const SizedBox.shrink();
    final count = _savedDrafts.length;
    final latestDraft = _savedDrafts.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: Color(0xFF008744),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 1
                      ? 'Draf Formulir Tersimpan ($count)'
                      : 'Draf Tim Tersimpan',
                  style: AppTextStyles.labelMd.copyWith(
                    color: const Color(0xFF14532D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  latestDraft.namaTim.isEmpty
                      ? 'Ketuk untuk melihat daftar draf tim'
                      : 'Terakhir: "${latestDraft.namaTim}"',
                  style: AppTextStyles.bodySm.copyWith(
                    color: const Color(0xFF166534),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _openDraftsModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008744),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              count > 1 ? 'Lihat Draf' : 'Lanjutkan',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _vm.loadMyTeams,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Jika layar lebar (> 600px seperti laptop/desktop/tablet), tampilkan Grid 2 atau 3 kolom
          if (constraints.maxWidth > 600) {
            final crossAxisCount = constraints.maxWidth > 960 ? 3 : 2;
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 295,
              ),
              itemCount: _vm.myTeams.length,
              itemBuilder: (_, i) {
                final team = _vm.myTeams[i];
                return TeamCard(
                  team: team,
                  onTap: () => _navigateToDetail(team.idTim),
                  onEdit: team.isOwner ? () => _openEditModal(team) : null,
                  onDelete: team.isOwner
                      ? () => _confirmDelete(team.idTim, team.namaTim)
                      : null,
                );
              },
            );
          }

          // Layar mobile standar: List vertikal dengan kartu petak
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _vm.myTeams.length,
            itemBuilder: (_, i) {
              final team = _vm.myTeams[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TeamCard(
                  team: team,
                  onTap: () => _navigateToDetail(team.idTim),
                  onEdit: team.isOwner ? () => _openEditModal(team) : null,
                  onDelete: team.isOwner
                      ? () => _confirmDelete(team.idTim, team.namaTim)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreate,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.add_rounded),
      label: Text('Buat Tim', style: AppTextStyles.labelLg),
    );
  }

  Future<void> _openEditModal(TeamModel team) async {
    final result = await TeamManagementEditModal.show(
      context,
      team: team,
      viewModel: _vm,
    );
    if (result == true) {
      _vm.loadMyTeams();
    }
  }

  Future<void> _openDraftsModal() async {
    final selectedDraft = await TeamDraftsModal.show(context);
    _checkDraft();
    if (selectedDraft != null && mounted) {
      _navigateToCreate(initialDraft: selectedDraft);
    }
  }

  Future<void> _navigateToCreate({TeamDraftModel? initialDraft}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TeamManagementCreateScreen(
          viewModel: _vm,
          initialDraft: initialDraft,
        ),
      ),
    );
    _checkDraft();
    if (result == true) _vm.loadMyTeams();
  }

  Future<void> _navigateToDetail(String idTim) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TeamManagementDetailScreen(idTim: idTim, viewModel: _vm),
      ),
    );
    _vm.loadMyTeams();
  }
}
