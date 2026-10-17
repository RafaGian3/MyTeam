import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../models/feed_team_model.dart';
import '../../../talent_search/models/talent_member_model.dart';
import '../../services/team_feed_service.dart';
import '../../../profile/views/screens/profile_screen.dart';
import '../../../team_management/views/screens/team_management_screen.dart';
import '../../../talent_search/views/screens/talent_search_screen.dart';
import '../../../talent_search/views/screens/received_invitations_screen.dart';
<<<<<<< HEAD
import '../../../talent_search/views/screens/member_detail_screen.dart';
import 'team_feed_detail_screen.dart';
=======
import '../../../talent_search/services/talent_search_service.dart';
>>>>>>> 48a9dfe71620a8e694b04ee2fc8529c84ecf2973

/// Home Screen — MyTeam
/// Feed utama: Rekomendasi Tim, Talenta Mahasiswa, CTA Buat Tim
/// Data real-time dari backend API MyTeam
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Session ───────────────────────────────────────────────────────────────
  String _nama = '';
  String _token = '';
  String _myUserId = '';
  int _currentTab = 0;

  // ── Badge Notifikasi (FR-25) ──────────────────────────────────────────────
  int _unreadNotif = 0; // jumlah notifikasi belum dibaca
  Timer? _notifTimer; // penyegar badge berkala

  // ── Data ──────────────────────────────────────────────────────────────────
  List<TeamModel> _teams = [];
  List<MemberModel> _members = [];
  bool _loadingTeams = true;
  bool _loadingMembers = true;
  String? _teamError;

  // ── Filter & Search ───────────────────────────────────────────────────────
  String _selectedKategori = 'Semua';
  String? _selectedKeahlian;
  final _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  static const _kategoriList = ['Semua', 'Lomba', 'Penelitian', 'Proyek', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _initSession();
    _loadUnreadNotif();
    // Segarkan badge tiap 30 detik agar notifikasi baru muncul tanpa membuka ulang aplikasi
    _notifTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentTab != 3) _loadUnreadNotif();
    });
  }

  // Ambil jumlah notifikasi belum dibaca untuk badge
  Future<void> _loadUnreadNotif() async {
    final jumlah = await TalentSearchService.getUnreadNotificationCount();
    if (mounted) setState(() => _unreadNotif = jumlah);
  }

  // Dipanggil saat ikon navigasi bawah ditekan
  Future<void> _onNavTap(int idx) async {
    final sebelumnya = _currentTab;
    setState(() => _currentTab = idx);
    if (idx == 3 || sebelumnya == 3) {
      // Membuka (atau meninggalkan) tab Notifikasi: semua dianggap sudah dibaca
      await TalentSearchService.markAllNotificationsRead();
      if (mounted) setState(() => _unreadNotif = 0);
    } else {
      await _loadUnreadNotif();
    }
  }

  Future<void> _initSession() async {
    _nama = await StorageService.getNama() ?? 'Mahasiswa';
    _token = await StorageService.getToken() ?? '';
    _myUserId = await StorageService.getUserId() ?? '';
    if (mounted) setState(() {});
    await Future.wait([_loadTeams(), _loadMembers()]);
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _loadTeams(search: value.trim());
    });
    setState(() {});
  }

  Future<void> _loadTeams({String? search}) async {
    setState(() {
      _loadingTeams = true;
      _teamError = null;
    });
    try {
      final query = search ?? _searchCtrl.text.trim();
      final teams = await TeamService.fetchFeed(
        token: _token,
        search: query.isNotEmpty ? query : null,
        kategori: _selectedKategori == 'Semua' ? null : _selectedKategori,
        keahlian: (_selectedKeahlian != null &&
                _selectedKeahlian!.trim().isNotEmpty)
            ? _selectedKeahlian!.trim()
            : null,
      );
      if (mounted) setState(() => _teams = teams);
    } catch (e) {
      if (mounted) {
        setState(
            () => _teamError = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final members = await TeamService.searchMembers(token: _token);
      if (mounted) setState(() => _members = members);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _debounceTimer?.cancel();
=======
    _notifTimer?.cancel();
>>>>>>> 48a9dfe71620a8e694b04ee2fc8529c84ecf2973
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentTab == 4 ? null : _buildAppBar(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey<int>(_currentTab),
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return _buildFeedBody();
      case 1:
        // FR-21, FR-22, FR-23 — Modul 4 Diva Ramadhani
        return const TalentSearchScreen();
      case 2:
        return const TeamManagementScreen();
      case 3:
        // FR-24: Undangan Masuk + FR-25: Respon undangan & notifikasi
        return const ReceivedInvitationsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget? _buildAppBar() {
    switch (_currentTab) {
      case 0:
        return _buildBrandedAppBar('Feed & Rekomendasi Kegiatan');
      case 1:
        // TalentSearchScreen manages its own header; AppBar still shown above
        return _buildBrandedAppBar('Eksplorasi & Pencarian Talenta');
      case 2:
      case 4:
        return null;
      case 3:
        // ReceivedInvitationsScreen has its own AppBar
        return null;
      default:
        return null;
    }
  }

  PreferredSizeWidget _buildBrandedAppBar(String subtitle) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
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
                subtitle,
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
            onPressed: () {
              if (_currentTab == 0) {
                _loadTeams();
                _loadMembers();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman diperbarui.'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Segarkan Halaman',
          ),
        ),
      ],
    );
  }

  // ── Feed Body ─────────────────────────────────────────────────────────────
  Widget _buildFeedBody() {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await Future.wait([_loadTeams(), _loadMembers()]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildWelcomeSection()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildKategoriChips()),
          SliverToBoxAdapter(child: _buildActiveFilters()),
          SliverToBoxAdapter(child: _buildCtaBanner()),
          SliverToBoxAdapter(
              child: _buildSectionHeader('Feed Tim & Rekomendasi Kegiatan')),
          SliverToBoxAdapter(child: _buildTeamSection()),
          SliverToBoxAdapter(
              child: _buildSectionHeader('Talenta Mahasiswa',
                  subtitle: 'Calon anggota se-Universitas Andalas')),
          SliverToBoxAdapter(child: _buildMemberSection()),
          SliverToBoxAdapter(child: _buildStatsBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Welcome Section ───────────────────────────────────────────────────────
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Halo, ',
                        style: AppTextStyles.headlineMd.copyWith(fontSize: 20),
                      ),
                      TextSpan(
                        text: '$_nama! ',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(
                        text: '👋',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan tim impianmu hari ini',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    final isFilterActive = _selectedKategori != 'Semua' ||
        (_selectedKeahlian != null && _selectedKeahlian!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _searchCtrl.text.isNotEmpty
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.bodyMd,
                onChanged: _onSearchChanged,
                onSubmitted: (v) => _loadTeams(search: v.trim()),
                decoration: InputDecoration(
                  hintText: 'Cari tim, kegiatan, atau keahlian...',
                  hintStyle: AppTextStyles.bodySm,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded,
                              size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchCtrl.clear();
                            _loadTeams(search: '');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openFilterModal,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isFilterActive
                        ? AppColors.primary
                        : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                ),
                if (isFilterActive)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Kategori Chips ────────────────────────────────────────────────────────
  Widget _buildKategoriChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriList.length,
        itemBuilder: (context, i) {
          final k = _kategoriList[i];
          final isSelected = k == _selectedKategori;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedKategori = k);
              _loadTeams();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                k,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Active Filter Strip ───────────────────────────────────────────────────
  Widget _buildActiveFilters() {
    final hasKategoriFilter = _selectedKategori != 'Semua';
    final hasKeahlianFilter =
        _selectedKeahlian != null && _selectedKeahlian!.isNotEmpty;
    final hasSearchFilter = _searchCtrl.text.trim().isNotEmpty;

    if (!hasKategoriFilter && !hasKeahlianFilter && !hasSearchFilter) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Filter aktif:',
            style: AppTextStyles.bodySm.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          if (hasKategoriFilter)
            _buildActiveFilterChip(
              label: 'Kategori: $_selectedKategori',
              onDeleted: () {
                setState(() => _selectedKategori = 'Semua');
                _loadTeams();
              },
            ),
          if (hasKeahlianFilter)
            _buildActiveFilterChip(
              label: 'Keahlian: $_selectedKeahlian',
              onDeleted: () {
                setState(() => _selectedKeahlian = null);
                _loadTeams();
              },
            ),
          if (hasSearchFilter)
            _buildActiveFilterChip(
              label: '"${_searchCtrl.text.trim()}"',
              onDeleted: () {
                _searchCtrl.clear();
                _loadTeams(search: '');
                setState(() {});
              },
            ),
          GestureDetector(
            onTap: _resetAllFilters,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Reset Semua',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.statusDangerText,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primaryOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Modal Bottom Sheet Filter (FR-14) ──────────────────────────────────────
  void _openFilterModal() {
    String tempKategori = _selectedKategori;
    String? tempKeahlian = _selectedKeahlian;
    final keahlianCtrl = TextEditingController(text: _selectedKeahlian ?? '');

    const skillSuggestions = [
      'Flutter',
      'UI/UX',
      'Python',
      'Machine Learning',
      'Data Science',
      'IoT / Hardware',
      'Web Backend',
      'Scientific Writing',
      'Public Speaking',
      'Graphic Design',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter & Penyaringan Tim',
                                style: AppTextStyles.headlineMd
                                    .copyWith(fontSize: 17),
                              ),
                              Text(
                                'Sesuaikan kriteria pencarian kegiatan',
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Text(
                      'Kategori Kegiatan',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kategoriList.map((kat) {
                        final isSel = kat == tempKategori;
                        return ChoiceChip(
                          label: Text(kat),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => tempKategori = kat);
                            }
                          },
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: Colors.white,
                          labelStyle: AppTextStyles.bodySm.copyWith(
                            color: isSel ? Colors.white : AppColors.text,
                            fontWeight:
                                isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSel
                                ? AppColors.primaryContainer
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Keahlian yang Dibutuhkan',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: keahlianCtrl,
                        style: AppTextStyles.bodyMd,
                        onChanged: (val) {
                          setModalState(() => tempKeahlian = val.trim());
                        },
                        decoration: InputDecoration(
                          hintText: 'Ketik keahlian (misal: Flutter, Python)...',
                          hintStyle: AppTextStyles.bodySm,
                          prefixIcon: const Icon(Icons.psychology_outlined,
                              size: 18, color: AppColors.textMuted),
                          suffixIcon: keahlianCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 16, color: AppColors.textMuted),
                                  onPressed: () {
                                    keahlianCtrl.clear();
                                    setModalState(() => tempKeahlian = null);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Rekomendasi Keahlian Populer:',
                      style: AppTextStyles.bodySm.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skillSuggestions.map((skill) {
                        final isChosen = tempKeahlian?.toLowerCase() ==
                            skill.toLowerCase();
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isChosen) {
                                tempKeahlian = null;
                                keahlianCtrl.clear();
                              } else {
                                tempKeahlian = skill;
                                keahlianCtrl.text = skill;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? AppColors.primarySoft
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: isChosen
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isChosen) ...[
                                  const Icon(Icons.check_rounded,
                                      size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  skill,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: isChosen
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    fontWeight: isChosen
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _resetAllFilters();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.border, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reset Filter',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedKategori = tempKategori;
                                  final typed = keahlianCtrl.text.trim();
                                  _selectedKeahlian = typed.isNotEmpty
                                      ? typed
                                      : tempKeahlian;
                                });
                                _loadTeams();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Terapkan Filter',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _resetAllFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedKategori = 'Semua';
      _selectedKeahlian = null;
    });
    _loadTeams(search: '');
  }

  // ── CTA Banner ────────────────────────────────────────────────────────────
  Widget _buildCtaBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006400), Color(0xFF008000)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '🚀 KOLABORASI CEPAT',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Punya Ide Kegiatan?',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buat tim impianmu dan temukan talenta terbaik se-Universitas Andalas!',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      setState(() => _currentTab = 2);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buat Tim',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 38),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title,
      {String? subtitle, VoidCallback? onLihatSemua}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMd.copyWith(fontSize: 17)),
                if (subtitle != null)
                  Text(subtitle, style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
              ],
            ),
          ),
          if (onLihatSemua != null)
            GestureDetector(
              onTap: onLihatSemua,
              child: Text(
                'Lihat Semua →',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Team Section ──────────────────────────────────────────────────────────
  Widget _buildTeamSection() {
    if (_loadingTeams) {
      return Column(
        children: List.generate(3, (i) => _buildTeamCardSkeleton()),
      );
    }
    if (_teamError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.statusDangerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.statusDangerText, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _teamError!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.statusDangerText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => _loadTeams(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusDangerText,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_teams.isEmpty) {
      final isFiltered = _searchCtrl.text.trim().isNotEmpty ||
          _selectedKategori != 'Semua' ||
          (_selectedKeahlian != null && _selectedKeahlian!.isNotEmpty);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isFiltered
                      ? const Color(0xFFFEF3C7)
                      : AppColors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFiltered
                        ? const Color(0xFFFDE68A)
                        : AppColors.primaryOutline,
                  ),
                ),
                child: Icon(
                  isFiltered ? Icons.search_off_rounded : Icons.groups_outlined,
                  size: 32,
                  color: isFiltered
                      ? const Color(0xFFD97706)
                      : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isFiltered
                    ? 'Tidak Ada Tim Ditemukan'
                    : 'Belum Ada Tim Terbuka',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFiltered
                    ? 'Tidak ditemukan tim yang cocok dengan kata kunci atau filter yang Anda terapkan.\nCoba ubah kriteria pencarian.'
                    : 'Belum ada tim yang membuka lowongan anggota saat ini.\nJadilah yang pertama membuat tim!',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isFiltered)
                ElevatedButton.icon(
                  onPressed: _resetAllFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: const Text('Hapus Filter & Pencarian'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => setState(() => _currentTab = 2),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Buat Tim Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _teams.map((team) => _buildTeamCard(team)).toList(),
    );
  }

  Widget _buildTeamCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Row(
            children: [
              Container(width: 3.5, color: AppColors.primaryOutline),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 170,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.surfaceContainer,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 64,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTeamCard(TeamModel team) {
    final kategoriColor = _kategoriColor(team.kategori);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamFeedDetailScreen(
                  idTim: team.idTim,
                  namaTim: team.namaTim,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Left accent border (DESIGN.md 3.3: 3.5px green) ───────────
                    Container(
                      width: 3.5,
                      color: _kategoriAccentColor(team.kategori),
                    ),
                    // ── Card Content ──────────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row: kategori badge + bookmark
                            Row(
                              children: [
                                _buildBadge(team.kategori, kategoriColor.$1,
                                    kategoriColor.$2),
                                const SizedBox(width: 6),
                                if (team.kategori == 'Lomba')
                                  _buildBadge(
                                      'Kompetisi',
                                      AppColors.statusPendingBg,
                                      AppColors.statusPendingText),
                                const Spacer(),
                                const Icon(Icons.bookmark_border_rounded,
                                    color: AppColors.textMuted, size: 20),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Nama Tim
                            Text(
                              team.namaTim,
                              style:
                                  AppTextStyles.titleMd.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),

                            // Nama Kegiatan
                            Row(
                              children: [
                                const Icon(Icons.event_note_outlined,
                                    size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    team.namaKegiatan,
                                    style: AppTextStyles.bodySm
                                        .copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 20, color: AppColors.border),

                            // Kebutuhan Tim & Status Kuota
                            if (team.kebutuhanTim.isNotEmpty) ...[
                              Row(
                                children: [
                                  Text(
                                    'Dibutuhkan:',
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: team.totalPosisiTerbuka <= 1
                                          ? AppColors.statusDangerBg
                                          : AppColors.statusSuccessBg,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      team.totalPosisiTerbuka <= 1
                                          ? 'Sisa ${team.totalPosisiTerbuka} Posisi'
                                          : '${team.totalPosisiTerbuka} Posisi Terbuka',
                                      style: AppTextStyles.labelSm.copyWith(
                                        fontSize: 10,
                                        color: team.totalPosisiTerbuka <= 1
                                            ? AppColors.statusDangerText
                                            : AppColors.statusSuccessText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: team.kebutuhanTim
                                    .take(3)
                                    .map((k) => _buildSkillChip(k.posisi))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Ketua tim + info anggota + tombol Detail
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: AppColors.primarySoft,
                                  backgroundImage: (team.fotoProfil != null &&
                                          team.fotoProfil!.isNotEmpty &&
                                          team.fotoProfil!.startsWith('http'))
                                      ? NetworkImage(team.fotoProfil!)
                                      : null,
                                  child: (team.fotoProfil == null ||
                                          team.fotoProfil!.isEmpty ||
                                          !team.fotoProfil!.startsWith('http'))
                                      ? Text(
                                          team.namaPengguna.isNotEmpty
                                              ? team.namaPengguna[0]
                                                  .toUpperCase()
                                              : 'T',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        team.namaPengguna,
                                        style: AppTextStyles.bodySm.copyWith(
                                          fontSize: 11.5,
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        team.totalAnggotaSaatIni > 0
                                            ? '${team.totalAnggotaSaatIni} Anggota Bergabung'
                                            : 'Ketua Tim',
                                        style: AppTextStyles.bodySm.copyWith(
                                          fontSize: 9.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Detail',
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white, size: 13),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Member Section (Talenta) ───────────────────────────────────────────────
  Widget _buildMemberSection() {
    if (_loadingMembers) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryContainer, strokeWidth: 2.5),
        ),
      );
    }
    if (_members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _members.length,
        itemBuilder: (context, i) => _buildMemberCard(_members[i]),
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: (member.fotoProfil != null &&
                            member.fotoProfil!.isNotEmpty &&
                            member.fotoProfil!.startsWith('http'))
                        ? NetworkImage(member.fotoProfil!)
                        : null,
                    child: (member.fotoProfil == null ||
                            member.fotoProfil!.isEmpty ||
                            !member.fotoProfil!.startsWith('http'))
                        ? Text(
                            member.inisial,
                            style: AppTextStyles.titleMd.copyWith(
                                color: AppColors.primary, fontSize: 14),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
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
            ],
          ),
          const SizedBox(height: 8),

          // Nama
          Text(
            member.namaPengguna,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Prodi + Angkatan
          Text(
            '${member.programStudi} ${member.angkatan}',
            style: AppTextStyles.bodySm.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Keahlian chips
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: member.keahlian
                .take(2)
                .map((k) => _buildSkillChip(k, fontSize: 9))
                .toList(),
          ),
          const Spacer(),

          // Lihat Profil
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberDetailScreen(
                    member: member,
                    myUserId: _myUserId,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryOutline, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Profil',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.primary, size: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Banner ──────────────────────────────────────────────────────────
  Widget _buildStatsBanner() {
    final total = _teams.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryOutline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded,
                  color: AppColors.primaryContainer, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total Tim Aktif Tersedia',
                    style: AppTextStyles.titleMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bergabung & wujudkan kolaborasi hebat',
                    style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up_rounded,
                color: AppColors.primaryContainer, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _bottomNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              _bottomNavItem(1, Icons.search_rounded, Icons.search_rounded, 'Cari'),
              _bottomNavItem(2, Icons.groups_outlined, Icons.groups_rounded, 'MyTeam'),
              _bottomNavItem(3, Icons.notifications_none_rounded, Icons.notifications_rounded, 'Notifikasi'),
              _bottomNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(int idx, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentTab == idx;
    return Expanded(
      child: InkWell(
        onTap: () => _onNavTap(idx),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
                // Badge jumlah notifikasi belum dibaca (hanya di ikon Notifikasi)
                if (idx == 3 && _unreadNotif > 0 && !isActive)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        _unreadNotif > 99 ? '99+' : '$_unreadNotif',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 10),
      ),
    );
  }

  Widget _buildSkillChip(String label, {double fontSize = 10}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '• $label',
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.textMuted,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _kategoriAccentColor(String kategori) {
    return switch (kategori) {
      'Lomba' => AppColors.categoryCompetitionText,
      'Penelitian' => AppColors.categoryResearchText,
      'Proyek' => AppColors.statusPendingText,
      _ => AppColors.primaryContainer,
    };
  }

  (Color, Color) _kategoriColor(String kategori) {
    return switch (kategori) {
      'Lomba' => (AppColors.categoryCompetitionBg, AppColors.categoryCompetitionText),
      'Penelitian' => (AppColors.categoryResearchBg, AppColors.categoryResearchText),
      'Proyek' => (AppColors.statusPendingBg, AppColors.statusPendingText),
      _ => (AppColors.surfaceContainer, AppColors.textMuted),
    };
  }
}
