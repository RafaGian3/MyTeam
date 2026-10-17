import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../models/talent_member_model.dart';

/// Service untuk endpoint Modul 4 (FR-21, FR-22, FR-23, FR-24, FR-25)
/// PIC: Diva Ramadhani (2411521017)
class TalentSearchService {
  // FR-21: GET /api/v1/members/search
  static Future<List<TalentMemberModel>> searchMembers({
    String? q,
    String? keahlian,
    String? minat,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (keahlian != null && keahlian.isNotEmpty) params['keahlian'] = keahlian;
    if (minat != null && minat.isNotEmpty) params['minat'] = minat;

    final resp = await ApiClient.get('/members/search', queryParams: params);
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data
          .map((e) => TalentMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat data anggota.');
  }

  // FR-22: GET /api/v1/profile/detail/{id_pengguna}
  static Future<Map<String, dynamic>> getMemberDetail(String idPengguna) async {
    final resp = await ApiClient.get('/profile/detail/$idPengguna');
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      return json['data'] as Map<String, dynamic>;
    }
    throw Exception(json['message'] ?? 'Gagal memuat detail profil.');
  }

  // FR-23: POST /api/v1/applications/invite-member
  static Future<Map<String, dynamic>> inviteMember({
    required String idTim,
    required String idPengguna,
    required String posisi,
    required String pesanPengajuan,
  }) async {
    final resp = await ApiClient.post(
      '/applications/invite-member',
      body: {
        'id_tim': idTim,
        'id_pengguna': idPengguna,
        'posisi': posisi,
        'pesan_pengajuan': pesanPengajuan,
      },
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((resp.statusCode == 200 || resp.statusCode == 201) &&
        json['success'] == true) {
      return json['data'] as Map<String, dynamic>;
    }
    throw Exception(json['message'] ?? 'Gagal mengirim undangan.');
  }

  // FR-24: GET /api/v1/applications/received-invitations
  static Future<List<Map<String, dynamic>>> getReceivedInvitations(
    String idPengguna,
  ) async {
    final resp = await ApiClient.get(
      '/applications/received-invitations',
      queryParams: {'id_pengguna': idPengguna},
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat daftar undangan.');
  }

  // FR-24 + FR-25: PATCH /api/v1/applications/received-invitations/{id}/status
  static Future<Map<String, dynamic>> respondInvitation({
    required String idPengajuanAnggota,
    required String status,
  }) async {
    final resp = await ApiClient.patch(
      '/applications/received-invitations/$idPengajuanAnggota/status',
      body: {'status_pengajuan': status},
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Gagal memperbarui status undangan.');
    }

    final data = json['data'];
    if (data is! Map<String, dynamic> ||
        !['diterima', 'ditolak'].contains(data['status_pengajuan'])) {
      throw Exception('Respons status undangan dari server tidak valid.');
    }
    final message = json['message'];
    if (message is! String || message.isEmpty) {
      throw Exception('Pesan respons undangan dari server tidak tersedia.');
    }

    return {'status_pengajuan': data['status_pengajuan'], 'message': message};
  }

  // FR-25: GET /api/v1/applications/sent-invitations
  // Undangan yang sudah dikirim oleh user (sebagai ketua tim) + statusnya
  static Future<List<Map<String, dynamic>>> getSentInvitations(
    String idPengguna,
  ) async {
    final resp = await ApiClient.get(
      '/applications/sent-invitations',
      queryParams: {'id_pengguna': idPengguna},
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(
      json['message'] ?? 'Gagal memuat daftar undangan terkirim.',
    );
  }

  // FR-25: GET /api/v1/notifications/unread-count
  // Jumlah notifikasi belum dibaca untuk badge ikon Notifikasi.
  // Tidak pernah melempar error: jika gagal, badge cukup dianggap 0.
  static Future<int> getUnreadNotificationCount() async {
    try {
      final resp = await ApiClient.get('/notifications/unread-count');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && json['success'] == true) {
        final data = json['data'] as Map<String, dynamic>?;
        return int.tryParse(data?['unread_count']?.toString() ?? '') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  // FR-25: PATCH /api/v1/notifications/read-all
  // Menandai semua notifikasi sudah dibaca saat tab Notifikasi dibuka.
  static Future<void> markAllNotificationsRead() async {
    try {
      await ApiClient.patch('/notifications/read-all');
    } catch (_) {}
  }
}
