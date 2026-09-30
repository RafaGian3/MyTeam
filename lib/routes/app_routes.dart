import 'package:flutter/material.dart';

import '../screens/catatan_form_screen.dart'; // [BARU]
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  // [BARU]
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String catatanForm = '/catatan-form'; // [BARU]

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case catatanForm: // [BARU]
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
