import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/team_model.dart';
import '../models/platform_upload_file.dart';

/// Service komunikasi API Modul 2 — Pembentukan & Manajemen Tim (FR-08..FR-11)
class TeamManagementService {
  // FR-09: Daftar tim milik pengguna
  static Future<List<TeamModel>> getMyTeams() async {
    final response = await ApiClient.get(ApiEndpoints.myTeams);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List<dynamic>? ?? [])
          .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['message'] ?? 'Gagal memuat daftar tim Anda.');
  }

  // FR-09: Detail tim (termasuk anggota & dokumen)
  static Future<TeamModel> getTeamDetail(String idTim) async {
    final response = await ApiClient.get('${ApiEndpoints.teams}/$idTim');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return TeamModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Gagal memuat detail tim.');
  }

  // FR-08: Buat tim baru (multipart/form-data)
  static Future<TeamModel> createTeam({
    required String namaTim,
    required String namaKegiatan,
    required String kategoriKegiatan,
    required String deskripsi,
    required List<KebutuhanTimModel> kebutuhan,
    List<PlatformUploadFile>? dokumenFiles,
  }) async {
    final request = await _buildMultipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.teams,
    );

    request.fields['nama_tim'] = namaTim;
    request.fields['nama_kegiatan'] = namaKegiatan;
    request.fields['kategori_kegiatan'] = kategoriKegiatan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['kebutuhan'] =
        jsonEncode(kebutuhan.map((e) => e.toJson()).toList());

    _attachDocuments(request, dokumenFiles);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    if ((response.statusCode == 201 || response.statusCode == 200) &&
        data['success'] == true) {
      return TeamModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Gagal membuat tim.');
  }

  // FR-10: Update informasi tim (kategori dikunci)
  static Future<TeamModel> updateTeam({
    required String idTim,
    required String namaTim,
    required String namaKegiatan,
    required String deskripsi,
    required String statusTim,
    required List<KebutuhanTimModel> kebutuhan,
    List<PlatformUploadFile>? dokumenFiles,
  }) async {
    final request = await _buildMultipartRequest(
      method: 'POST',
      endpoint: '${ApiEndpoints.teams}/$idTim/update',
    );

    request.fields['_method'] = 'PUT';
    request.fields['nama_tim'] = namaTim;
    request.fields['nama_kegiatan'] = namaKegiatan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['status_tim'] = statusTim;
    request.fields['kebutuhan'] =
        jsonEncode(kebutuhan.map((e) => e.toJson()).toList());

    _attachDocuments(request, dokumenFiles);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return TeamModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Gagal memperbarui tim.');
  }

  // FR-11: Hapus tim
  static Future<void> deleteTeam(String idTim) async {
    final response = await ApiClient.delete('${ApiEndpoints.teams}/$idTim');
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal menghapus tim.');
    }
  }

  // Helpers
  static Future<http.MultipartRequest> _buildMultipartRequest({
    required String method,
    required String endpoint,
  }) async {
    final token = await StorageService.getToken();
    final request = http.MultipartRequest(
      method,
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }
    return request;
  }

  static void _attachDocuments(
    http.MultipartRequest request,
    List<PlatformUploadFile>? files,
  ) {
    if (files == null || files.isEmpty) return;
    for (int i = 0; i < files.length; i++) {
      final f = files[i];
      request.files.add(
        http.MultipartFile.fromBytes(
          'dokumen_pendukung',
          f.bytes,
          filename: f.name,
        ),
      );
      request.fields['jenis_dokumen[$i]'] = f.jenis;
    }
  }
}
