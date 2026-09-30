import 'package:flutter/material.dart';

import '../models/team.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/not_found_screen.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const detail = '/detail';
  static const catatanForm = '/catatan-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => AuthScreen(
            onAuthenticated: () {
              Navigator.pushReplacementNamed(context, home);
            },
          ),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case detail:
        final args = settings.arguments;
        if (args is Team) {
          return MaterialPageRoute(
            builder: (_) => DetailScreen(team: args),
            settings: settings,
          );
        }
        // Jika arguments tidak valid, arahkan ke NotFoundScreen
        return onUnknownRoute(settings);

      case catatanForm:
        // Mengembalikan MaterialPageRoute<String> agar pop dapat membawa nilai String
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );

      default:
        return onUnknownRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
      settings: settings,
    );
  }
}
