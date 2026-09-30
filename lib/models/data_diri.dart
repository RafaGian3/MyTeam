// FR-01: Model data diri pengguna sesuai ERD MyTeam
class DataDiri {
  const DataDiri({
    required this.idPengguna,
    required this.deskripsiSingkat,
    required this.kontak,
    required this.programStudi,
    required this.fakultas,
    required this.ipk,
  });

  final String idPengguna;
  final String deskripsiSingkat;
  final String kontak;
  final String programStudi;
  final String fakultas;
  final double ipk;

  /// Buat salinan DataDiri dengan field yang diubah (untuk update)
  DataDiri copyWith({
    String? idPengguna,
    String? deskripsiSingkat,
    String? kontak,
    String? programStudi,
    String? fakultas,
    double? ipk,
  }) {
    return DataDiri(
      idPengguna: idPengguna ?? this.idPengguna,
      deskripsiSingkat: deskripsiSingkat ?? this.deskripsiSingkat,
      kontak: kontak ?? this.kontak,
      programStudi: programStudi ?? this.programStudi,
      fakultas: fakultas ?? this.fakultas,
      ipk: ipk ?? this.ipk,
    );
  }
}
