import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../routes/app_routes.dart'; // [BARU]
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/team_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: provider.selectedTab == 0 ? 0 : 1,
          children: [
            const _DashboardContent(),
            _PlaceholderTab(title: _tabTitle(provider.selectedTab)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: provider.selectedTab,
        onSelected: provider.setSelectedTab,
      ),
      floatingActionButton: provider.selectedTab == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateTeam(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static String _tabTitle(int index) =>
      ['Beranda', 'Cari', 'Status', 'Profil'][index];

  static void _showCreateTeam(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buat Tim Baru', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi nama tim, kegiatan, kategori, deskripsi, posisi, dan keahlian yang dibutuhkan sesuai data tim pada PRD.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mulai Mengisi'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth > 600 ? 48.0 : 16.0;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 0),
              sliver: SliverToBoxAdapter(child: _TopBar()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 0),
              sliver: SliverToBoxAdapter(child: _ProfileGreeting()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 0),
              sliver: SliverToBoxAdapter(
                child: _SearchBar(onChanged: provider.setSearchQuery),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
              sliver: SliverToBoxAdapter(
                child: _CategoryChips(
                  selected: provider.selectedCategory,
                  onSelected: provider.setCategory,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 0),
              sliver: const SliverToBoxAdapter(child: _CreateTeamBanner()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeading(
                  title: 'Rekomendasi Tim',
                  action: 'Lihat Semua ›',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 0),
              sliver: SliverList.builder(
                itemCount: provider.filteredTeams.length,
                itemBuilder: (context, index) =>
                    TeamCard(team: provider.filteredTeams[index]),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
              sliver: const SliverToBoxAdapter(
                child: SectionHeading(
                  title: 'Talenta Mahasiswa',
                  action: 'Geser untuk melihat',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
              sliver: SliverToBoxAdapter(
                child: _TalentList(provider: provider),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
              sliver: const SliverToBoxAdapter(child: _ActiveStats()),
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(
          Icons.account_tree_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      const SizedBox(width: 10),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UNAND COLLAB',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text('Home', style: AppTextStyles.title),
        ],
      ),
      const Spacer(),
      Stack(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 26),
          ),
          Positioned(
            right: 7,
            top: 5,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      IconButton(
        tooltip: 'Keluar',
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        ), // [BARU]
        icon: const Icon(Icons.logout_rounded),
      ),
      const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primarySoft,
        child: Text(
          'FP',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _ProfileGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const CircleAvatar(
        radius: 27,
        backgroundColor: AppColors.primarySoft,
        child: Text(
          'FP',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Halo, '),
                  TextSpan(
                    text: 'Fuadi!',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: ' 👋'),
                ],
              ),
              style: AppTextStyles.body,
            ),
            SizedBox(height: 2),
            Text(
              "Mahasiswa Sistem Informasi '22",
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.lavender,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.text,
        ),
      ),
    ],
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Cari tim, kegiatan, atau keahlian...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedText),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.mutedText,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFA9F08D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.tune_rounded, color: AppColors.primaryDark),
      ),
    ],
  );
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['Semua', 'Lomba', 'Penelitian', 'Proyek', 'UI/UX']
          .map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
                selectedColor: AppColors.primaryDark,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected == category
                      ? Colors.white
                      : AppColors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _CreateTeamBanner extends StatelessWidget {
  const _CreateTeamBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22006007),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '🚀 KOLABORASI CEPAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Punya Ide\nKegiatan?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Buat tim impianmu sekarang dan temukan talenta terbaik se-Unand!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => HomeScreen._showCreateTeam(context),
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  foregroundColor: const WidgetStatePropertyAll(
                    AppColors.primaryDark,
                  ),
                ),
                child: const Text('Buat Tim  →'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
      ],
    ),
  );
}

class _TalentList extends StatelessWidget {
  const _TalentList({required this.provider});
  final AppProvider provider;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: provider.talents.length,
      separatorBuilder: (_, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final talent = provider.talents[index];
        return Container(
          width: 235,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      talent.avatarLabel,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(talent.name, style: AppTextStyles.title),
                        Text(
                          talent.major,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                children: talent.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderStrong,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.text,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lavender,
                  ),
                  child: const Text(
                    'Lihat Profil  ♙',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _ActiveStats extends StatelessWidget {
  const _ActiveStats();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          backgroundColor: Color(0xFFDCE8DF),
          child: Icon(Icons.groups_rounded, color: AppColors.primaryDark),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('128+ Tim Aktif Pekan Ini', style: AppTextStyles.label),
            Text(
              'Bergabung & wujudkan kolaborasi hebat',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        Spacer(),
        Icon(Icons.trending_up_rounded, color: AppColors.mutedText),
      ],
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 8,
    color: Colors.white,
    child: SizedBox(
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.home_outlined,
            label: 'Beranda',
            onSelected: onSelected,
          ),
          _NavItem(
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.search_rounded,
            label: 'Cari',
            onSelected: onSelected,
          ),
          const SizedBox(width: 52),
          _NavItem(
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.checklist_rounded,
            label: 'Status',
            onSelected: onSelected,
          ),
          _NavItem(
            index: 3,
            selectedIndex: selectedIndex,
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            onSelected: onSelected,
          ),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onSelected,
  });
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    return InkWell(
      onTap: () => onSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryDark : AppColors.mutedText,
            ),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primaryDark : AppColors.mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.construction_rounded,
          color: AppColors.primary,
          size: 42,
        ),
        const SizedBox(height: 12),
        Text('$title segera hadir', style: AppTextStyles.title),
        const SizedBox(height: 4),
        const Text(
          'Navigasi sudah siap untuk modul berikutnya.',
          style: AppTextStyles.caption,
        ),
      ],
    ),
  );
}
