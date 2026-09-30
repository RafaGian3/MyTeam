import 'package:flutter/material.dart';

import '../models/data_diri.dart';
import '../models/team.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/profile/data_diri_form_screen.dart'; // FR-01
import '../screens/profile/data_diri_screen.dart'; // FR-01

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const detail = '/detail';
  static const catatanForm = '/catatan-form';
  static const dataDiri = '/data-diri'; // FR-01
  static const dataDiriForm = '/data-diri-form'; // FR-01

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
        return onUnknownRoute(settings);

      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );

      // FR-01: Route halaman data diri
      case dataDiri:
        return MaterialPageRoute(
          builder: (_) => const DataDiriScreen(),
          settings: settings,
        );

      // FR-01: Route form data diri — argument opsional (DataDiri | null)
      case dataDiriForm:
        final args = settings.arguments;
        return MaterialPageRoute<DataDiri>(
          builder: (_) => DataDiriFormScreen(
            existing: args is DataDiri ? args : null,
          ),
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
