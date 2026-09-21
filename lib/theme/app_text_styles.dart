import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const heading = TextStyle(
    color: AppColors.text,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    height: 1.4,
  );
  static const caption = TextStyle(
    color: AppColors.mutedText,
    fontSize: 12,
    height: 1.35,
  );
  static const label = TextStyle(
    color: AppColors.text,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
