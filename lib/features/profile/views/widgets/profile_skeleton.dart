import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Komponen Skeleton Box dengan warna netral terstandarisasi
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(8)),
        shape: shape,
      ),
    );
  }
}

/// Skeleton Screen untuk Layar Profil Mahasiswa (Modul 1)
/// Mengikuti struktur visual persis: Hero Profile Card, Segmented Pill Bar, dan Kartu-Kartu Profil
class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulseAnimation,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 1. Hero Profile Card Skeleton
          _buildHeroCardSkeleton(),
          const SizedBox(height: 12),

          // 2. Segmented Pill Bar Skeleton
          _buildTabBarSkeleton(),
          const SizedBox(height: 16),

          // 3. Card 1: Tentang Saya Skeleton
          _buildTentangCardSkeleton(),
          const SizedBox(height: 16),

          // 4. Card 2: Akademik Skeleton
          _buildAkademikCardSkeleton(),
          const SizedBox(height: 16),

          // 5. Card 3: Kontak Skeleton
          _buildKontakCardSkeleton(),
          const SizedBox(height: 16),

          // 6. Card 4: Media Sosial Skeleton
          _buildMedsosCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildHeroCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkeletonBox(width: 72, height: 72, shape: BoxShape.circle),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(width: 140, height: 18),
                SizedBox(height: 6),
                SkeletonBox(width: 90, height: 12),
                SizedBox(height: 8),
                SkeletonBox(width: 85, height: 18),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: SkeletonBox(width: 60, height: 12),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Center(child: SkeletonBox(width: 16, height: 16)),
          ),
          const Expanded(
            flex: 2,
            child: Center(child: SkeletonBox(width: 16, height: 16)),
          ),
          const Expanded(
            flex: 2,
            child: Center(child: SkeletonBox(width: 16, height: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTentangCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 30, height: 30),
              SizedBox(width: 10),
              SkeletonBox(width: 95, height: 16),
              Spacer(),
              SkeletonBox(width: 45, height: 16),
            ],
          ),
          SizedBox(height: 14),
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 7),
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 7),
          SkeletonBox(width: 180, height: 12),
        ],
      ),
    );
  }

  Widget _buildAkademikCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 30, height: 30),
              SizedBox(width: 10),
              SkeletonBox(width: 80, height: 16),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              SkeletonBox(width: 24, height: 24),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 70, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 140, height: 13),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              SkeletonBox(width: 24, height: 24),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 60, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 130, height: 13),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              SkeletonBox(width: 24, height: 24),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 110, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 60, height: 13),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKontakCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 30, height: 30),
              SizedBox(width: 10),
              SkeletonBox(width: 60, height: 16),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              SkeletonBox(width: 38, height: 38),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 120, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 100, height: 14),
                ],
              ),
              Spacer(),
              SkeletonBox(width: 74, height: 26, borderRadius: BorderRadius.all(Radius.circular(20))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedsosCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SkeletonBox(width: 30, height: 30),
              SizedBox(width: 10),
              SkeletonBox(width: 130, height: 16),
              Spacer(),
              SkeletonBox(width: 50, height: 16),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                SkeletonBox(width: 20, height: 20),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 65, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(width: 120, height: 10),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                SkeletonBox(width: 20, height: 20),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 75, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(width: 140, height: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
