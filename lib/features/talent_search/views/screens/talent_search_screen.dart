import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../models/talent_member_model.dart';
import '../../services/talent_search_service.dart';
import 'member_detail_screen.dart';

/// Halaman Pencarian Talenta (Tab "Cari" — Bottom Nav Index 1)
/// FR-21: Pencarian calon anggota berdasarkan nama, keahlian, minat, prodi
/// PIC Modul 4: Diva Ramadhani (2411521017)
class TalentSearchScreen extends StatefulWidget {
  const TalentSearchScreen({super.key});

  @override
  State<TalentSearchScreen> createState() => _TalentSearchScreenState();
}

class _TalentSearchScreenState extends State<TalentSearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ── Controllers & State ──────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  String _myUserId = '';
  List<TalentMemberModel> _members = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMsg;

  // ── Active filters ────────────────────────────────────────────────────────
  String? _activeFilterKeahlian;
  String? _activeFilterMinat;

  // ── Dynamic filter options (diekstrak dari hasil search) ─────────────────
  List<String> _dynamicKeahlian = [];
  List<String> _dynamicMinat = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await StorageService.getUserId() ?? '';
    await _loadAll();
  }

  Future<void> _loadAll({String? q, String? keahlian, String? minat}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final results = await TalentSearchService.searchMembers(
        q: q,
        keahlian: keahlian,
        minat: minat,
      );
      if (mounted) {
        setState(() {
          _members = results;
          // Rebuild filter options dari hasil fetch (hanya saat load tanpa filter aktif)
          if (keahlian == null && minat == null) {
            _rebuildFilterOptions(results);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    setState(() => _hasSearched = q.isNotEmpty || _hasActiveFilter);
    _loadAll(
      q: q.isNotEmpty ? q : null,
      keahlian: _activeFilterKeahlian,
      minat: _activeFilterMinat,
    );
    _focusNode.unfocus();
  }

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear();
      _activeFilterKeahlian = null;
      _activeFilterMinat = null;
      _hasSearched = false;
    });
    _loadAll();
  }

  bool get _hasActiveFilter =>
      _activeFilterKeahlian != null || _activeFilterMinat != null;

  // ── Ekstrak filter unik dari data mahasiswa ──────────────────────────────
  void _rebuildFilterOptions(List<TalentMemberModel> members) {
    final keahlianSet = <String>{};
    final minatSet = <String>{};
    for (final m in members) {
      keahlianSet.addAll(m.keahlian);
      minatSet.addAll(m.minat);
    }
    final sortedKeahlian = keahlianSet.toList()..sort();
    final sortedMinat = minatSet.toList()..sort();
    // Batasi max 20 agar UI tidak overflow
    _dynamicKeahlian = sortedKeahlian.take(20).toList();
    _dynamicMinat = sortedMinat.take(20).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          controller: _scrollCtrl,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildKeahlianRow()),
            SliverToBoxAdapter(child: _buildMinatRow()),
            if (_hasActiveFilter)
              SliverToBoxAdapter(child: _buildActiveFilterBanner()),
            SliverToBoxAdapter(child: _buildResultsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Talenta',
                  style: AppTextStyles.headlineLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Temukan calon anggota tim terbaik Universitas Andalas',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.primaryOutline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_rounded,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${_members.length}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar (DESIGN.md 3.5: 48px, focus border #008000) ───────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.borderFocused
                      : AppColors.border,
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                style: AppTextStyles.bodyMd,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari nama, NIM, atau program studi...',
                  hintStyle: AppTextStyles.bodySm.copyWith(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                            _onSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // CTA Search Button
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Keahlian Chips ─────────────────────────────────────────────────
  Widget _buildKeahlianRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 13, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(
                'Filter Keahlian',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _dynamicKeahlian.isEmpty ? 1 : _dynamicKeahlian.length,
            itemBuilder: (_, i) {
              // Loading state — tampilkan skeleton chips
              if (_dynamicKeahlian.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Memuat...',
                      style: AppTextStyles.bodySm.copyWith(
                          fontSize: 12, color: AppColors.textMuted)),
                );
              }
              final k = _dynamicKeahlian[i];
              final isSelected = _activeFilterKeahlian == k;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilterKeahlian = isSelected ? null : k;
                  });
                  _onSearch();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    k,
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Filter Minat Chips ────────────────────────────────────────────────────
  Widget _buildMinatRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.interests_rounded,
                  size: 13, color: AppColors.categoryResearchText),
              const SizedBox(width: 5),
              Text(
                'Filter Minat',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _dynamicMinat.isEmpty ? 1 : _dynamicMinat.length,
            itemBuilder: (_, i) {
              if (_dynamicMinat.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Memuat...',
                      style: AppTextStyles.bodySm.copyWith(
                          fontSize: 12, color: AppColors.textMuted)),
                );
              }
              final m = _dynamicMinat[i];
              final isSelected = _activeFilterMinat == m;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilterMinat = isSelected ? null : m;
                  });
                  _onSearch();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.categoryResearchBg
                        : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.categoryResearchText
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    m,
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.categoryResearchText
                          : AppColors.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Active Filter Banner ──────────────────────────────────────────────────
  Widget _buildActiveFilterBanner() {
    final labels = [
      ?_activeFilterKeahlian,
      ?_activeFilterMinat,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryOutline),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list_rounded,
                color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filter aktif: ${labels.join(" & ")}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Text(
                'Reset',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.statusDangerText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results Section ───────────────────────────────────────────────────────
  Widget _buildResultsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _hasSearched ? 'Hasil Pencarian' : 'Semua Talenta Mahasiswa',
                  style: AppTextStyles.headlineMd.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            _buildLoadingSkeletons()
          else if (_errorMsg != null)
            _buildErrorState()
          else if (_members.isEmpty)
            _buildEmptyState()
          else
            ...(_members.map(_buildCandidateCard)),
        ],
      ),
    );
  }

  // ── Loading Skeleton ──────────────────────────────────────────────────────
  Widget _buildLoadingSkeletons() {
    return Column(children: List.generate(4, (_) => _buildSkeletonCard()));
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(140, 14),
                const SizedBox(height: 6),
                _shimmerBox(100, 11),
                const SizedBox(height: 8),
                Row(
                    children: List.generate(
                        3,
                        (_) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _shimmerBox(56, 22, radius: 99),
                            ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 4}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Tidak ada mahasiswa ditemukan',
                style: AppTextStyles.titleMd),
            const SizedBox(height: 6),
            Text(
              'Coba ubah kata kunci atau reset filter',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Reset Pencarian',
                    style: AppTextStyles.labelLg.copyWith(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusDangerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.statusDangerText.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.statusDangerText, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_errorMsg!,
                  style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.statusDangerText)),
            ),
            TextButton(
              onPressed: _loadAll,
              child: Text('Coba Lagi',
                  style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.statusDangerText)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Candidate Card (DESIGN.md 3.2) ───────────────────────────────────────
  Widget _buildCandidateCard(TalentMemberModel member) {
    return GestureDetector(
      onTap: () => _openDetail(member),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris Atas: Avatar + Nama + Prodi ────────────────────────
            Row(
              children: [
                // Avatar 44px (DESIGN.md 3.2)
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: (member.fotoProfil != null &&
                              member.fotoProfil!.isNotEmpty &&
                              member.fotoProfil!.startsWith('http'))
                          ? NetworkImage(member.fotoProfil!) as ImageProvider
                          : null,
                      child: (member.fotoProfil == null ||
                              member.fotoProfil!.isEmpty ||
                              !member.fotoProfil!.startsWith('http'))
                          ? Text(member.inisial,
                              style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.primary, fontSize: 16))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: const BoxDecoration(
                          color: AppColors.statusSuccessText,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.namaPengguna,
                        style:
                            AppTextStyles.titleMd.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.programStudi} • ${member.fakultas}',
                        style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // IPK badge
                if (member.ipk != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'IPK ${member.ipk!.toStringAsFixed(2)}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.statusSuccessText,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Baris Tengah: Deskripsi + Skills ────────────────────────
            if (member.deskripsiSingkat.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                member.deskripsiSingkat,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (member.keahlian.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: member.keahlian
                    .take(4)
                    .map(_buildSkillChip)
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // ── Baris Bawah: Pengalaman + Lihat Profil ──────────────────
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    size: 14,
                    color: AppColors.categoryCompetitionText),
                const SizedBox(width: 4),
                Text(
                  member.pengalamanLabel,
                  style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openDetail(member),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primaryOutline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Profil',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.primary, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(TalentMemberModel member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberDetailScreen(
          member: member,
          myUserId: _myUserId,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primaryOutline),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primary,
          fontSize: 10,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
