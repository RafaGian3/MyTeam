/// FR-03: Minat Mahasiswa
class MinatModel {
  final String idMinat;
  final String? idPengguna;
  final String minat;
  final String deskripsiMinat;

  const MinatModel({
    required this.idMinat,
    this.idPengguna,
    required this.minat,
    required this.deskripsiMinat,
  });

  factory MinatModel.fromJson(Map<String, dynamic> json) {
    return MinatModel(
      idMinat: json['id_minat']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString(),
      minat: json['minat']?.toString() ?? '',
      deskripsiMinat: json['deskripsi_minat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_minat': idMinat,
        'id_pengguna': idPengguna,
        'minat': minat,
        'deskripsi_minat': deskripsiMinat,
      };
}
