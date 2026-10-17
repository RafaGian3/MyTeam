/// Model data tim yang dibuat pengguna (Modul 2 — FR-08 s/d FR-12)
class TeamModel {
  final String idTim;
  final String idPengguna;
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String deskripsi;
  final String statusTim;
  final bool isOwner;
  final String? createdAt;
  final List<KebutuhanTimModel> kebutuhanTim;
  final List<DokumenPendukungModel> dokumenPendukung;
  final List<AnggotaTimModel> anggotaTim;

  const TeamModel({
    required this.idTim,
    required this.idPengguna,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.deskripsi,
    required this.statusTim,
    this.isOwner = false,
    this.createdAt,
    this.kebutuhanTim = const [],
    this.dokumenPendukung = const [],
    this.anggotaTim = const [],
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      idTim: json['id_tim']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString() ?? '',
      namaTim: json['nama_tim']?.toString() ?? '',
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      kategoriKegiatan: json['kategori_kegiatan']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      statusTim: json['status_tim']?.toString() ?? 'terbuka',
      isOwner: json['peran']?.toString() == 'pemilik',
      createdAt: json['created_at']?.toString(),
      kebutuhanTim: (json['kebutuhan_tim'] as List<dynamic>? ?? [])
          .map((e) => KebutuhanTimModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dokumenPendukung: (json['dokumen_pendukung'] as List<dynamic>? ?? [])
          .map((e) => DokumenPendukungModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      anggotaTim: (json['anggota_tim'] as List<dynamic>? ?? [])
          .map((e) => AnggotaTimModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_tim': idTim,
    'id_pengguna': idPengguna,
    'nama_tim': namaTim,
    'nama_kegiatan': namaKegiatan,
    'kategori_kegiatan': kategoriKegiatan,
    'deskripsi': deskripsi,
    'status_tim': statusTim,
    'peran': isOwner ? 'pemilik' : 'anggota',
    'kebutuhan_tim': kebutuhanTim.map((e) => e.toJson()).toList(),
    'dokumen_pendukung': dokumenPendukung.map((e) => e.toJson()).toList(),
    'anggota_tim': anggotaTim.map((e) => e.toJson()).toList(),
  };

  TeamModel copyWith({
    String? idTim,
    String? idPengguna,
    String? namaTim,
    String? namaKegiatan,
    String? kategoriKegiatan,
    String? deskripsi,
    String? statusTim,
    bool? isOwner,
    String? createdAt,
    List<KebutuhanTimModel>? kebutuhanTim,
    List<DokumenPendukungModel>? dokumenPendukung,
    List<AnggotaTimModel>? anggotaTim,
  }) {
    return TeamModel(
      idTim: idTim ?? this.idTim,
      idPengguna: idPengguna ?? this.idPengguna,
      namaTim: namaTim ?? this.namaTim,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      kategoriKegiatan: kategoriKegiatan ?? this.kategoriKegiatan,
      deskripsi: deskripsi ?? this.deskripsi,
      statusTim: statusTim ?? this.statusTim,
      isOwner: isOwner ?? this.isOwner,
      createdAt: createdAt ?? this.createdAt,
      kebutuhanTim: kebutuhanTim ?? this.kebutuhanTim,
      dokumenPendukung: dokumenPendukung ?? this.dokumenPendukung,
      anggotaTim: anggotaTim ?? this.anggotaTim,
    );
  }
}

/// Model kebutuhan anggota tim (posisi & keahlian yang dicari)
class KebutuhanTimModel {
  final String? idKebutuhan;
  final String posisiDibutuhkan;
  final String keahlianDibutuhkan;
  final int jumlahAnggotaDibutuhkan;

  const KebutuhanTimModel({
    this.idKebutuhan,
    required this.posisiDibutuhkan,
    required this.keahlianDibutuhkan,
    this.jumlahAnggotaDibutuhkan = 1,
  });

  factory KebutuhanTimModel.fromJson(Map<String, dynamic> json) {
    return KebutuhanTimModel(
      idKebutuhan: json['id_kebutuhan']?.toString(),
      posisiDibutuhkan: json['posisi_dibutuhkan']?.toString() ?? '',
      keahlianDibutuhkan: json['keahlian_dibutuhkan']?.toString() ?? '',
      jumlahAnggotaDibutuhkan:
          (json['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    if (idKebutuhan != null) 'id_kebutuhan': idKebutuhan,
    'posisi_dibutuhkan': posisiDibutuhkan,
    'keahlian_dibutuhkan': keahlianDibutuhkan,
    'jumlah_anggota_dibutuhkan': jumlahAnggotaDibutuhkan,
  };

  KebutuhanTimModel copyWith({
    String? idKebutuhan,
    String? posisiDibutuhkan,
    String? keahlianDibutuhkan,
    int? jumlahAnggotaDibutuhkan,
  }) {
    return KebutuhanTimModel(
      idKebutuhan: idKebutuhan ?? this.idKebutuhan,
      posisiDibutuhkan: posisiDibutuhkan ?? this.posisiDibutuhkan,
      keahlianDibutuhkan: keahlianDibutuhkan ?? this.keahlianDibutuhkan,
      jumlahAnggotaDibutuhkan:
          jumlahAnggotaDibutuhkan ?? this.jumlahAnggotaDibutuhkan,
    );
  }
}

/// Model dokumen pendukung tim (poster/panduan)
class DokumenPendukungModel {
  final String? idDokumen;
  final String jenisDokumen;
  final String namaFile;
  final String pathFile;
  final int urutan;

  const DokumenPendukungModel({
    this.idDokumen,
    required this.jenisDokumen,
    required this.namaFile,
    required this.pathFile,
    this.urutan = 1,
  });

  factory DokumenPendukungModel.fromJson(Map<String, dynamic> json) {
    return DokumenPendukungModel(
      idDokumen: json['id_dokumen']?.toString(),
      jenisDokumen: json['jenis_dokumen']?.toString() ?? 'poster',
      namaFile: json['nama_file']?.toString() ?? '',
      pathFile: json['path_file']?.toString() ?? '',
      urutan: (json['urutan'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    if (idDokumen != null) 'id_dokumen': idDokumen,
    'jenis_dokumen': jenisDokumen,
    'nama_file': namaFile,
    'path_file': pathFile,
    'urutan': urutan,
  };
}

/// Model anggota yang sudah bergabung ke tim
class AnggotaTimModel {
  final String idAnggotaTim;
  final String idPengguna;
  final String? namaPengguna;
  final String? fotoProfil;
  final String? programStudi;
  final String posisi;

  const AnggotaTimModel({
    required this.idAnggotaTim,
    required this.idPengguna,
    this.namaPengguna,
    this.fotoProfil,
    this.programStudi,
    required this.posisi,
  });

  factory AnggotaTimModel.fromJson(Map<String, dynamic> json) {
    return AnggotaTimModel(
      idAnggotaTim: json['id_anggota_tim']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString() ?? '',
      namaPengguna: json['nama_pengguna']?.toString(),
      fotoProfil: json['foto_profil']?.toString(),
      programStudi: json['program_studi']?.toString(),
      posisi: json['posisi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_anggota_tim': idAnggotaTim,
    'id_pengguna': idPengguna,
    'posisi': posisi,
  };
}
