import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/profile_detail_model.dart';

/// Service untuk menangani komunikasi API Akun & Data Riwayat Diri
class ProfileService {
  /// Mengambil data profil lengkap & riwayat tim yang diikuti
  static Future<ProfileDetailModel> getProfileDetail(String idPengguna) async {
    final response = await ApiClient.get('${ApiEndpoints.profileDetail}/$idPengguna');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileDetailModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode}');
    }
  }

  /// Simpan / Perbarui Data Diri & Akademik
  static Future<bool> updateDataDiri({
    required String idPengguna,
    required String deskripsiSingkat,
    required String kontak,
    required String programStudi,
    required String fakultas,
    required double ipk,
  }) async {
    final response = await ApiClient.put(
      ApiEndpoints.dataDiri,
      body: {
        'id_pengguna': idPengguna,
        'deskripsi_singkat': deskripsiSingkat,
        'kontak': kontak,
        'program_studi': programStudi,
        'fakultas': fakultas,
        'ipk': ipk,
      },
    );
    return response.statusCode == 200;
  }

  /// Update Foto Profil (Preset Avatar / URL)
  static Future<bool> updateFotoProfil({
    required String idPengguna,
    required String fotoUrl,
  }) async {
    final response = await ApiClient.put(
      ApiEndpoints.fotoProfil,
      body: {
        'id_pengguna': idPengguna,
        'foto_url': fotoUrl,
      },
    );
    return response.statusCode == 200;
  }

  /// Upload Berkas Foto Profil dari Kamera atau Galeri (Multipart/Form-Data)
  static Future<String?> uploadFotoProfilFile({
    required String filePath,
    required String idPengguna,
  }) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse('${AppConfig.baseUrl}${ApiEndpoints.fotoProfil}');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['id_pengguna'] = idPengguna;
    request.files.add(await http.MultipartFile.fromPath('foto_profil', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fotoUrl = data['data']?['foto_profil'] as String?;
      return fotoUrl;
    } else {
      throw Exception('Gagal mengunggah foto profil (${response.statusCode})');
    }
  }

  // ─── FR-02: Media Sosial ──────────────────────────────────────────────────
  static Future<bool> addMediaSosial({
    required String idPengguna,
    required String namaMediaSosial,
    required String linkMediaSosial,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.mediaSosial,
      body: {
        'id_pengguna': idPengguna,
        'nama_media_sosial': namaMediaSosial,
        'link_media_sosial': linkMediaSosial,
      },
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateMediaSosial({
    required String idMediaSosial,
    required String namaMediaSosial,
    required String linkMediaSosial,
  }) async {
    final response = await ApiClient.put(
      '${ApiEndpoints.mediaSosial}/$idMediaSosial',
      body: {
        'nama_media_sosial': namaMediaSosial,
        'link_media_sosial': linkMediaSosial,
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMediaSosial(String idMediaSosial) async {
    final response = await ApiClient.delete('${ApiEndpoints.mediaSosial}/$idMediaSosial');
    return response.statusCode == 200;
  }

  // ─── FR-03: Minat ─────────────────────────────────────────────────────────
  static Future<bool> addMinat({
    required String idPengguna,
    required String minat,
    required String deskripsiMinat,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.minat,
      body: {
        'id_pengguna': idPengguna,
        'minat': minat,
        'deskripsi_minat': deskripsiMinat,
      },
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateMinat({
    required String idMinat,
    required String minat,
    required String deskripsiMinat,
  }) async {
    final response = await ApiClient.put(
      '${ApiEndpoints.minat}/$idMinat',
      body: {
        'minat': minat,
        'deskripsi_minat': deskripsiMinat,
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMinat(String idMinat) async {
    final response = await ApiClient.delete('${ApiEndpoints.minat}/$idMinat');
    return response.statusCode == 200;
  }

  // ─── FR-04: Keahlian ──────────────────────────────────────────────────────
  static Future<bool> addKeahlian({
    required String idPengguna,
    required String keahlian,
    required String deskripsiKeahlian,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.keahlian,
      body: {
        'id_pengguna': idPengguna,
        'keahlian': keahlian,
        'deskripsi_keahlian': deskripsiKeahlian,
      },
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateKeahlian({
    required String idKeahlian,
    required String keahlian,
    required String deskripsiKeahlian,
  }) async {
    final response = await ApiClient.put(
      '${ApiEndpoints.keahlian}/$idKeahlian',
      body: {
        'keahlian': keahlian,
        'deskripsi_keahlian': deskripsiKeahlian,
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteKeahlian(String idKeahlian) async {
    final response = await ApiClient.delete('${ApiEndpoints.keahlian}/$idKeahlian');
    return response.statusCode == 200;
  }

  // ─── FR-05: Pengalaman ────────────────────────────────────────────────────
  static Future<bool> addPengalaman({
    required String idPengguna,
    required String namaKegiatan,
    required String peran,
    required int tahun,
    required String deskripsiPengalaman,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.pengalaman,
      body: {
        'id_pengguna': idPengguna,
        'nama_kegiatan': namaKegiatan,
        'peran': peran,
        'tahun': tahun,
        'deskripsi_pengalaman': deskripsiPengalaman,
      },
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updatePengalaman({
    required String idPengalaman,
    required String namaKegiatan,
    required String peran,
    required int tahun,
    required String deskripsiPengalaman,
  }) async {
    final response = await ApiClient.put(
      '${ApiEndpoints.pengalaman}/$idPengalaman',
      body: {
        'nama_kegiatan': namaKegiatan,
        'peran': peran,
        'tahun': tahun,
        'deskripsi_pengalaman': deskripsiPengalaman,
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletePengalaman(String idPengalaman) async {
    final response = await ApiClient.delete('${ApiEndpoints.pengalaman}/$idPengalaman');
    return response.statusCode == 200;
  }
}
