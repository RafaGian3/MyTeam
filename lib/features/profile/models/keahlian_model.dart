/// FR-04: Keahlian Mahasiswa
class KeahlianModel {
  final String idKeahlian;
  final String? idPengguna;
  final String keahlian;
  final String deskripsiKeahlian;

  const KeahlianModel({
    required this.idKeahlian,
    this.idPengguna,
    required this.keahlian,
    required this.deskripsiKeahlian,
  });

  factory KeahlianModel.fromJson(Map<String, dynamic> json) {
    return KeahlianModel(
      idKeahlian: json['id_keahlian']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString(),
      keahlian: json['keahlian']?.toString() ?? '',
      deskripsiKeahlian: json['deskripsi_keahlian']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_keahlian': idKeahlian,
        'id_pengguna': idPengguna,
        'keahlian': keahlian,
        'deskripsi_keahlian': deskripsiKeahlian,
      };
}
