import 'package:flutter/material.dart';

/// Design Tokens — MyTeam "Academic Emerald Synergy" Design System
/// Acuan: DESIGN.md v1.0.0
abstract final class AppColors {
  // ─── Brand & Emerald Unand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF006400);
  static const Color primaryContainer = Color(0xFF008000);
  static const Color primaryDark = Color(0xFF004D00);
  static const Color primarySoft = Color(0xFFE8F5E9);
  static const Color primaryOutline = Color(0xFFC8E6C9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFCCFFBA);

  // ─── Canvas & Surfaces ───────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFE);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF008000);

  // ─── Typography ──────────────────────────────────────────────────────────
  static const Color text = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  // ─── Status Semantics ────────────────────────────────────────────────────
  static const Color statusSuccessBg = Color(0xFFDCFCE7);
  static const Color statusSuccessText = Color(0xFF15803D);

  static const Color statusPendingBg = Color(0xFFFEF9C3);
  static const Color statusPendingText = Color(0xFFA16207);

  static const Color statusDangerBg = Color(0xFFFEE2E2);
  static const Color statusDangerText = Color(0xFFDC2626);

  static const Color categoryCompetitionBg = Color(0xFFFEF3C7);
  static const Color categoryCompetitionText = Color(0xFFD97706);

  static const Color categoryResearchBg = Color(0xFFDBEAFE);
  static const Color categoryResearchText = Color(0xFF2563EB);
}
