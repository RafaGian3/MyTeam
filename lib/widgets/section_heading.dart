import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 7, height: 23, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6))), const SizedBox(width: 9), Text(title, style: AppTextStyles.heading.copyWith(fontSize: 18)), const Spacer(), if (action != null) Text(action!, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700))]);
}
