/// Model kebutuhan posisi dalam satu tim
class KebutuhanModel {
  final String idKebutuhan;
  final String idTim;
  final String posisi;
  final String keahlian;
  final int jumlah;

  const KebutuhanModel({
    required this.idKebutuhan,
    required this.idTim,
    required this.posisi,
    required this.keahlian,
    required this.jumlah,
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> j) => KebutuhanModel(
        idKebutuhan: j['id_kebutuhan'] as String? ?? '',
        idTim: j['id_tim'] as String? ?? '',
        posisi: j['posisi_dibutuhkan'] as String? ?? '',
        keahlian: j['keahlian_dibutuhkan'] as String? ?? '',
        jumlah: (j['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1,
      );

  /// Keahlian dipecah menjadi list chip (dipisah koma)
  List<String> get keahlianList =>
      keahlian.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

/// Model dokumen pendukung tim (poster / panduan)
class DokumenPendukungModel {
  final String idDokumen;
  final String idTim;
  final String jenisDokumen;
  final String namaFile;
  final String pathFile;
  final int urutan;

  const DokumenPendukungModel({
    required this.idDokumen,
    required this.idTim,
    required this.jenisDokumen,
    required this.namaFile,
    required this.pathFile,
    required this.urutan,
  });

  factory DokumenPendukungModel.fromJson(Map<String, dynamic> j) =>
      DokumenPendukungModel(
        idDokumen: j['id_dokumen']?.toString() ?? '',
        idTim: j['id_tim']?.toString() ?? '',
        jenisDokumen: j['jenis_dokumen']?.toString() ?? 'poster',
        namaFile: j['nama_file']?.toString() ?? '',
        pathFile: j['path_file']?.toString() ?? '',
        urutan: (j['urutan'] as num?)?.toInt() ?? 1,
      );
}

/// Model pembuat tim
class PembuatTimModel {
  final String idPengguna;
  final String namaPengguna;
  final String? fotoProfil;

  const PembuatTimModel({
    required this.idPengguna,
    required this.namaPengguna,
    this.fotoProfil,
  });

  factory PembuatTimModel.fromJson(Map<String, dynamic> j) => PembuatTimModel(
        idPengguna: j['id_pengguna']?.toString() ?? '',
        namaPengguna: j['nama_pengguna']?.toString() ?? '',
        fotoProfil: j['foto_profil']?.toString(),
      );
}

/// Model tim dari endpoint GET /api/v1/teams/feed (FR-13 & FR-14)
class FeedTeamModel {
  final String idTim;
  final String idPengguna;
  final String namaTim;
  final String namaKegiatan;
  final String kategori; // Lomba | Penelitian | Proyek | Lainnya
  final String deskripsi;
  final String statusTim;
  final String namaPengguna; // nama ketua
  final String? fotoProfil;
  final List<KebutuhanModel> kebutuhanTim;
  final List<DokumenPendukungModel> dokumenPendukung;
  final int totalAnggotaSaatIni;
  final PembuatTimModel? pembuatTim;
  final String createdAt;

  const FeedTeamModel({
    required this.idTim,
    required this.idPengguna,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategori,
    required this.deskripsi,
    required this.statusTim,
    required this.namaPengguna,
    this.fotoProfil,
    required this.kebutuhanTim,
    this.dokumenPendukung = const [],
    this.totalAnggotaSaatIni = 0,
    this.pembuatTim,
    required this.createdAt,
  });

  factory FeedTeamModel.fromJson(Map<String, dynamic> j) {
    final kebutuhanRaw = j['kebutuhan_tim'] as List<dynamic>? ?? [];
    final dokumenRaw = j['dokumen_pendukung'] as List<dynamic>? ?? [];

    final pembuatRaw = j['pembuat_tim'] as Map<String, dynamic>?;
    final idPembuat = pembuatRaw?['id_pengguna']?.toString() ??
        j['id_pengguna']?.toString() ??
        '';
    final namaKetua = pembuatRaw?['nama_pengguna']?.toString() ??
        j['nama_pengguna']?.toString() ??
        '';
    final fotoKetua = pembuatRaw?['foto_profil']?.toString() ??
        j['foto_profil']?.toString();

    return FeedTeamModel(
      idTim: j['id_tim']?.toString() ?? '',
      idPengguna: idPembuat,
      namaTim: j['nama_tim']?.toString() ?? '',
      namaKegiatan: j['nama_kegiatan']?.toString() ?? '',
      kategori: j['kategori_kegiatan']?.toString() ?? 'Lainnya',
      deskripsi: j['deskripsi']?.toString() ?? '',
      statusTim: j['status_tim']?.toString() ?? 'terbuka',
      namaPengguna: namaKetua,
      fotoProfil: fotoKetua,
      kebutuhanTim: kebutuhanRaw
          .map((e) => KebutuhanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dokumenPendukung: dokumenRaw
          .map((e) => DokumenPendukungModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAnggotaSaatIni: (j['total_anggota_saat_ini'] as num?)?.toInt() ?? 0,
      pembuatTim:
          pembuatRaw != null ? PembuatTimModel.fromJson(pembuatRaw) : null,
      createdAt: j['created_at']?.toString() ?? '',
    );
  }

  int get totalPosisiTerbuka =>
      kebutuhanTim.fold(0, (sum, k) => sum + k.jumlah);

  /// Poster pertama jika ada
  String? get posterUrl {
    for (final d in dokumenPendukung) {
      if (d.jenisDokumen == 'poster' && d.pathFile.isNotEmpty) {
        return d.pathFile;
      }
    }
    return null;
  }
}

// Alias untuk kompatibilitas
typedef TeamModel = FeedTeamModel;

