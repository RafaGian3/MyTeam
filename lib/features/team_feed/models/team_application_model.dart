/// Ringkasan status lamaran pada tim (FR-17)
class TeamApplicationsSummary {
  final int total;
  final int menunggu;
  final int diterima;
  final int ditolak;

  const TeamApplicationsSummary({
    this.total = 0,
    this.menunggu = 0,
    this.diterima = 0,
    this.ditolak = 0,
  });

  factory TeamApplicationsSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TeamApplicationsSummary();
    return TeamApplicationsSummary(
      total: _asInt(json['total']),
      menunggu: _asInt(json['menunggu']),
      diterima: _asInt(json['diterima']),
      ditolak: _asInt(json['ditolak']),
    );
  }

  static int _asInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'menunggu': menunggu,
        'diterima': diterima,
        'ditolak': ditolak,
      };
}

/// Model untuk Pengajuan Bergabung Tim Masuk (FR-17 - Rafa Gian Atthari)
class TeamApplicationModel {
  final String idPengajuanBergabungTim;
  final String idTim;
  final String idPengguna;
  final String posisi;
  final String pesanPengajuan;
  final String waktuPengajuan;
  final String statusPengajuan; // 'menunggu' | 'diterima' | 'ditolak'
  final String namaPengguna;
  final String nim;
  final String? fotoProfil;
  final String? programStudi;
  final String? fakultas;
  final String? ipk;
  final String? kontak;
  final String? namaTim;
  final String? namaKegiatan;

  const TeamApplicationModel({
    required this.idPengajuanBergabungTim,
    required this.idTim,
    required this.idPengguna,
    required this.posisi,
    required this.pesanPengajuan,
    required this.waktuPengajuan,
    required this.statusPengajuan,
    required this.namaPengguna,
    required this.nim,
    this.fotoProfil,
    this.programStudi,
    this.fakultas,
    this.ipk,
    this.kontak,
    this.namaTim,
    this.namaKegiatan,
  });

  bool get isMenunggu => statusPengajuan.toLowerCase() == 'menunggu';
  bool get isDiterima => statusPengajuan.toLowerCase() == 'diterima';
  bool get isDitolak => statusPengajuan.toLowerCase() == 'ditolak';

  /// Format tanggal & waktu pengajuan ramah pengguna
  String get formattedDate {
    if (waktuPengajuan.isEmpty) return '-';
    try {
      final dt = DateTime.parse(waktuPengajuan).toLocal();
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final month = monthNames[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year}, $hour:$minute';
    } catch (_) {
      return waktuPengajuan;
    }
  }

  /// Format relatif (e.g. "2 jam lalu", "Hari ini", "Kemarin")
  String get relativeTime {
    if (waktuPengajuan.isEmpty) return '';
    try {
      final dt = DateTime.parse(waktuPengajuan).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return formattedDate;
    } catch (_) {
      return waktuPengajuan;
    }
  }

  factory TeamApplicationModel.fromJson(Map<String, dynamic> json) {
    return TeamApplicationModel(
      idPengajuanBergabungTim:
          (json['id_pengajuan_bergabung_tim'] ?? '').toString(),
      idTim: (json['id_tim'] ?? '').toString(),
      idPengguna: (json['id_pengguna'] ?? '').toString(),
      posisi: (json['posisi'] ?? '').toString(),
      pesanPengajuan: (json['pesan_pengajuan'] ?? '').toString(),
      waktuPengajuan: (json['waktu_pengajuan'] ?? '').toString(),
      statusPengajuan: (json['status_pengajuan'] ?? 'menunggu').toString(),
      namaPengguna: (json['nama_pengguna'] ?? 'Mahasiswa').toString(),
      nim: (json['nim'] ?? '-').toString(),
      fotoProfil: json['foto_profil']?.toString(),
      programStudi: json['program_studi']?.toString(),
      fakultas: json['fakultas']?.toString(),
      ipk: json['ipk']?.toString(),
      kontak: json['kontak']?.toString(),
      namaTim: json['nama_tim']?.toString(),
      namaKegiatan: json['nama_kegiatan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengajuan_bergabung_tim': idPengajuanBergabungTim,
        'id_tim': idTim,
        'id_pengguna': idPengguna,
        'posisi': posisi,
        'pesan_pengajuan': pesanPengajuan,
        'waktu_pengajuan': waktuPengajuan,
        'status_pengajuan': statusPengajuan,
        'nama_pengguna': namaPengguna,
        'nim': nim,
        'foto_profil': fotoProfil,
        'program_studi': programStudi,
        'fakultas': fakultas,
        'ipk': ipk,
        'kontak': kontak,
        'nama_tim': namaTim,
        'nama_kegiatan': namaKegiatan,
      };
}

/// Struktur kembalian lengkap dari endpoint GET /api/v1/teams/:id_tim/applications
class TeamApplicationsResult {
  final bool success;
  final String message;
  final String idTim;
  final String namaTim;
  final String namaKegiatan;
  final TeamApplicationsSummary summary;
  final List<TeamApplicationModel> applications;

  const TeamApplicationsResult({
    required this.success,
    required this.message,
    required this.idTim,
    required this.namaTim,
    required this.namaKegiatan,
    required this.summary,
    required this.applications,
  });

  factory TeamApplicationsResult.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final list = json['data'] as List<dynamic>? ?? [];

    return TeamApplicationsResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      idTim: (team['id_tim'] ?? '').toString(),
      namaTim: (team['nama_tim'] ?? '').toString(),
      namaKegiatan: (team['nama_kegiatan'] ?? '').toString(),
      summary: TeamApplicationsSummary.fromJson(summaryJson),
      applications: list
          .map((e) => TeamApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
