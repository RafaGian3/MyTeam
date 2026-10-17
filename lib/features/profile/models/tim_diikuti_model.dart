/// FR-06: Tim yang Diikuti Mahasiswa
class TimDiikutiModel {
  final String idAnggotaTim;
  final String idTim;
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String posisi;

  const TimDiikutiModel({
    required this.idAnggotaTim,
    required this.idTim,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.posisi,
  });

  factory TimDiikutiModel.fromJson(Map<String, dynamic> json) {
    return TimDiikutiModel(
      idAnggotaTim: json['id_anggota_tim']?.toString() ?? '',
      idTim: json['id_tim']?.toString() ?? '',
      namaTim: json['nama_tim']?.toString() ?? '',
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      kategoriKegiatan: json['kategori_kegiatan']?.toString() ?? 'Lomba',
      posisi: json['posisi']?.toString() ?? 'Anggota',
    );
  }
}
