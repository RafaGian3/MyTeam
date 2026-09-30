import 'package:flutter/material.dart';
import '../models/tim.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  // Constructor private agar class ini tidak bisa diinstansiasi
  AppRoutes._();

  // Konstanta route agar tidak ada typo saat navigasi
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  /// Dipanggil MaterialApp setiap ada navigasi dengan nama.
  /// Mengembalikan null jika route tidak terdaftar → onUnknownRoute dipanggil.
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
      case detail:
        // arguments harus bertipe Tim, dikirim dari HomeScreen
        final args = settings.arguments;
        if (args is Tim) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(tim: args),
            settings: settings,
          );
        }
        // Jika data salah/kosong, tampilkan 404
        return null;
      case catatanForm:
        // <String> karena layar ini mengembalikan teks saat ditutup
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar → halaman 404
    }
  }

  /// Dipanggil jika onGenerateRoute mengembalikan null (route tidak dikenal).
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
