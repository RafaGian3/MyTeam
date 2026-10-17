import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan dan membaca sesi pengguna (JWT token) secara lokal.
class StorageService {
  static const String _keyToken = 'myteam_token';
  static const String _keyUserId = 'myteam_user_id';
  static const String _keyNim = 'myteam_nim';
  static const String _keyNama = 'myteam_nama';
  static const String _keyFoto = 'myteam_foto';

  /// Simpan JWT token ke storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Ambil JWT token dari storage (null jika belum login)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Simpan data sesi pengguna setelah login berhasil
  static Future<void> saveUserSession({
    required String idPengguna,
    required String nim,
    required String namaPengguna,
    required String token,
    String? fotoProfil,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyToken, token),
      prefs.setString(_keyUserId, idPengguna),
      prefs.setString(_keyNim, nim),
      prefs.setString(_keyNama, namaPengguna),
      if (fotoProfil != null)
        prefs.setString(_keyFoto, fotoProfil)
      else
        prefs.remove(_keyFoto),
    ]);
  }

  /// Cek apakah pengguna sudah login (token tersedia)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Ambil ID pengguna dari storage
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Ambil nama pengguna dari storage
  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNama);
  }

  /// Ambil NIM pengguna dari storage
  static Future<String?> getNim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNim);
  }

  /// Ambil foto profil pengguna dari storage
  static Future<String?> getFoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFoto);
  }

  /// Hapus semua data sesi (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyToken),
      prefs.remove(_keyUserId),
      prefs.remove(_keyNim),
      prefs.remove(_keyNama),
      prefs.remove(_keyFoto),
    ]);
  }
}
