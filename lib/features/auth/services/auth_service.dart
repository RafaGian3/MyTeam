import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/auth_user_model.dart';

/// Service untuk menangani proses login dan registrasi akun mahasiswa
class AuthService {
  /// POST /api/v1/auth/login
  static Future<AuthUserModel> login({
    required String nim,
    required String kataSandi,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      body: {
        'nim': nim,
        'kata_sandi': kataSandi,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final user = AuthUserModel.fromJson(data);
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      return user;
    } else {
      throw Exception(data['message'] ?? 'Login gagal. Periksa NIM dan kata sandi.');
    }
  }

  /// POST /api/v1/auth/register
  static Future<AuthUserModel> register({
    required String nim,
    required String namaPengguna,
    required String kataSandi,
    required String kataSandiKonfirmasi,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      body: {
        'nim': nim,
        'nama_pengguna': namaPengguna,
        'kata_sandi': kataSandi,
        'kata_sandi_konfirmasi': kataSandiKonfirmasi,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      final user = AuthUserModel.fromJson(data);
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      return user;
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal.');
    }
  }

  /// Logout
  static Future<void> logout() async {
    await StorageService.clearSession();
  }
}
