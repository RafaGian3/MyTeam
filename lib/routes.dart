import 'package:flutter/material.dart';
import 'features/auth/views/screens/splash_screen.dart';
import 'features/auth/views/screens/login_screen.dart';
import 'features/auth/views/screens/register_screen.dart';
import 'features/team_feed/views/screens/home_feed_screen.dart';
import 'features/profile/views/screens/profile_screen.dart';
import 'features/team_management/views/screens/team_management_screen.dart';

/// Rute Navigasi Terpusat Aplikasi MyTeam (Feature-First Architecture)
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  // ── Modul 2: Team Management (sesuai folder lib/features/team_management)
  static const String teamManagement = '/team-management';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        profile: (context) => const ProfileScreen(),

        // Modul 2
        teamManagement: (context) => const TeamManagementScreen(),
      };
}

