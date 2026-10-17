import 'package:flutter/foundation.dart' show kIsWeb;

/// ============================================================
/// KONFIGURASI ENVIRONMENT — MyTeam Backend API
/// ============================================================
class AppConfig {
  /// Port backend MyTeam
  static const int _port = 8000;

  /// IP LAN laptop (opsional jika HP tanpa kabel USB & dalam satu jaringan Wi-Fi)
  static const String _lanIp = '192.168.100.11';

  /// Mode USB ADB Reverse (Sangat direkomendasikan saat HP dicolok kabel USB ke laptop):
  /// Menggunakan 127.0.0.1 via `adb reverse tcp:8000 tcp:8000` sehingga:
  /// 1. Bebas dari blokir Windows Firewall (Public Network).
  /// 2. Kebal terhadap perubahan IP Wi-Fi atau putusnya jaringan Wi-Fi.
  /// 3. Respon super cepat lewat jalur kabel USB.
  static const bool _useAdbReverse = true;

  /// Base URL API otomatis sesuai platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api/v1';
    }
    if (_useAdbReverse) {
      // Menghubungkan langsung ke backend laptop via adb reverse USB
      return 'http://127.0.0.1:$_port/api/v1';
    }
    // Fallback: IP LAN Wi-Fi
    return 'http://$_lanIp:$_port/api/v1';
  }
}
