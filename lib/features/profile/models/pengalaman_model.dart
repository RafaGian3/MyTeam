/// FR-05: Pengalaman Kegiatan Mahasiswa (Refinement PRD v1.0)
class PengalamanModel {
  final String idPengalaman;
  final String? idPengguna;
  final String namaKegiatan;
  final String peran;
  final int tahun;
  final String deskripsiPengalaman;

  const PengalamanModel({
    required this.idPengalaman,
    this.idPengguna,
    required this.namaKegiatan,
    required this.peran,
    required this.tahun,
    required this.deskripsiPengalaman,
  });

  factory PengalamanModel.fromJson(Map<String, dynamic> json) {
    return PengalamanModel(
      idPengalaman: json['id_pengalaman']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString(),
      namaKegiatan: json['nama_kegiatan']?.toString() ?? '',
      peran: json['peran']?.toString() ?? '',
      tahun: int.tryParse(json['tahun']?.toString() ?? '${DateTime.now().year}') ?? DateTime.now().year,
      deskripsiPengalaman: json['deskripsi_pengalaman']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengalaman': idPengalaman,
        'id_pengguna': idPengguna,
        'nama_kegiatan': namaKegiatan,
        'peran': peran,
        'tahun': tahun,
        'deskripsi_pengalaman': deskripsiPengalaman,
      };
}
