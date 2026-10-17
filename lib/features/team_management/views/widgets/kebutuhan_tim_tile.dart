import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/team_model.dart';

/// Row kebutuhan anggota tim (posisi + stepper kuota) untuk form buat/edit tim
/// Dipakai di CreateTeamScreen & EditTeamScreen
class KebutuhanTimTile extends StatelessWidget {
  final KebutuhanTimModel kebutuhan;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<KebutuhanTimModel> onChanged;

  const KebutuhanTimTile({
    super.key,
    required this.kebutuhan,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Posisi ke-N + tombol hapus
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Posisi ${index + 1}',
                  style: AppTextStyles.labelSm
                      .copyWith(color: Colors.white, letterSpacing: 0.2),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.statusDangerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Field: Nama Posisi
          _buildField(
            label: 'Nama Posisi',
            initialValue: kebutuhan.posisiDibutuhkan,
            hint: 'cth: Mobile Developer',
            onChanged: (val) =>
                onChanged(kebutuhan.copyWith(posisiDibutuhkan: val)),
          ),
          const SizedBox(height: 8),
          // Field: Keahlian dibutuhkan
          _buildField(
            label: 'Keahlian (pisah koma)',
            initialValue: kebutuhan.keahlianDibutuhkan,
            hint: 'cth: Flutter, REST API',
            onChanged: (val) =>
                onChanged(kebutuhan.copyWith(keahlianDibutuhkan: val)),
          ),
          const SizedBox(height: 10),
          // Stepper kuota
          Row(
            children: [
              Text('Kuota Anggota', style: AppTextStyles.labelMd),
              const Spacer(),
              _StepperButton(
                icon: Icons.remove,
                onTap: kebutuhan.jumlahAnggotaDibutuhkan > 1
                    ? () => onChanged(kebutuhan.copyWith(
                          jumlahAnggotaDibutuhkan:
                              kebutuhan.jumlahAnggotaDibutuhkan - 1,
                        ))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${kebutuhan.jumlahAnggotaDibutuhkan}',
                  style: AppTextStyles.titleMd,
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                onTap: () => onChanged(kebutuhan.copyWith(
                  jumlahAnggotaDibutuhkan:
                      kebutuhan.jumlahAnggotaDibutuhkan + 1,
                )),
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String initialValue,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySm,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _StepperButton({
    required this.icon,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.border
              : isPrimary
                  ? AppColors.primary
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: onTap == null
                ? AppColors.border
                : isPrimary
                    ? AppColors.primary
                    : AppColors.primaryOutline,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? AppColors.textMuted
              : isPrimary
                  ? Colors.white
                  : AppColors.primary,
        ),
      ),
    );
  }
}
