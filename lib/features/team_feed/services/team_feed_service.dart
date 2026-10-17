import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/network/api_client.dart';
import '../models/feed_team_model.dart';
import '../models/team_application_model.dart';
import '../../talent_search/models/talent_member_model.dart';

/// Service untuk endpoint Tim dan Talenta Anggota MyTeam
class TeamFeedService {
  static Map<String, String> _authHeader(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  /// GET /api/v1/teams/:id_tim/applications (FR-17: Pembuat Tim Melihat Daftar Pengajuan Masuk)
  static Future<TeamApplicationsResult> fetchTeamApplications(
    String idTim, {
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status != 'Semua' && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim().toLowerCase();
    }

    final response = await ApiClient.get(
      '/teams/$idTim/applications',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && json['success'] == true) {
      return TeamApplicationsResult.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Gagal memuat daftar pengajuan tim.');
  }

  /// GET /api/v1/applications/join-team/:id (FR-18: Detail Pengajuan)
  static Future<TeamApplicationModel> fetchApplicationDetail(
    String idPengajuan,
  ) async {
    final response = await ApiClient.get(
      '/applications/join-team/$idPengajuan',
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && json['success'] == true) {
      return TeamApplicationModel.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    }
    throw Exception(json['message'] ?? 'Gagal memuat detail pengajuan.');
  }

  /// PATCH /api/v1/applications/join-team/:id/status (FR-19: Terima / Tolak Pengajuan)
  static Future<Map<String, dynamic>> respondToApplication({
    required String idPengajuan,
    required String status,
  }) async {
    final response = await ApiClient.patch(
      '/applications/join-team/$idPengajuan/status',
      body: {'status_pengajuan': status},
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && json['success'] == true) {
      return (json['data'] as Map<String, dynamic>?) ?? {};
    }
    throw Exception(json['message'] ?? 'Gagal memperbarui status pengajuan.');
  }

  /// GET /api/v1/teams/feed/:id_tim (FR-15: Detail Tim untuk Calon Pelamar)
  static Future<Map<String, dynamic>> getTeamDetail(String idTim) async {
    final response = await ApiClient.get('/teams/feed/$idTim');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && json['success'] == true) {
      return json['data'] as Map<String, dynamic>;
    }
    throw Exception(json['message'] ?? 'Gagal memuat detail tim.');
  }

  /// POST /api/v1/applications/join-team (FR-16: Lamar Posisi Tim)
  static Future<Map<String, dynamic>> applyToTeam({
    required String idTim,
    required String posisi,
    required String pesanPengajuan,
  }) async {
    final userId = await StorageService.getUserId();
    final body = {
      'id_tim': idTim,
      'posisi': posisi,
      'pesan_pengajuan': pesanPengajuan,
      if (userId != null && userId.isNotEmpty) 'id_pengguna': userId,
    };

    final response = await ApiClient.post('/applications/join-team', body: body);
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 && json['success'] == true) {
      return (json['data'] as Map<String, dynamic>?) ?? {};
    }

    throw Exception(json['message'] ?? 'Gagal mengajukan lamaran ke tim.');
  }

  /// GET /api/v1/teams/feed
  static Future<List<FeedTeamModel>> fetchFeed({
    String token = '',
    String? search,
    String? kategori,
    String? keahlian,
  }) async {
    var authToken = token;
    if (authToken.isEmpty) {
      authToken = await StorageService.getToken() ?? '';
    }

    final params = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (kategori != null && kategori != 'Semua' && kategori.trim().isNotEmpty) {
      params['kategori'] = kategori.trim();
    }
    if (keahlian != null && keahlian.trim().isNotEmpty) {
      params['keahlian'] = keahlian.trim();
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/teams/feed')
        .replace(queryParameters: params.isEmpty ? null : params);

    late final http.Response resp;
    try {
      resp = await http
          .get(uri, headers: _authHeader(authToken))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Tidak dapat terhubung ke server.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data
          .map((e) => FeedTeamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat data tim.');
  }

  /// GET /api/v1/members/search
  static Future<List<TalentMemberModel>> searchMembers({
    String token = '',
    String? q,
    String? keahlian,
  }) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (keahlian != null && keahlian.isNotEmpty) params['keahlian'] = keahlian;

    final uri = Uri.parse('${AppConfig.baseUrl}/members/search')
        .replace(queryParameters: params.isEmpty ? null : params);

    late final http.Response resp;
    try {
      resp = await http
          .get(uri, headers: _authHeader(token))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Tidak dapat terhubung ke server.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data
          .map((e) => TalentMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat data anggota.');
  }
}

// Alias untuk kompatibilitas
typedef TeamService = TeamFeedService;
