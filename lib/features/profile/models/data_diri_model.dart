/// FR-01: Data Diri & Akademik Mahasiswa
class DataDiriModel {
  final String? idPengguna;
  final String deskripsiSingkat;
  final String kontak;
  final String programStudi;
  final String fakultas;
  final double ipk;

  const DataDiriModel({
    this.idPengguna,
    required this.deskripsiSingkat,
    required this.kontak,
    required this.programStudi,
    required this.fakultas,
    required this.ipk,
  });

  factory DataDiriModel.fromJson(Map<String, dynamic> json) {
    return DataDiriModel(
      idPengguna: json['id_pengguna']?.toString(),
      deskripsiSingkat: json['deskripsi_singkat']?.toString() ?? '',
      kontak: json['kontak']?.toString() ?? '',
      programStudi: json['program_studi']?.toString() ?? 'Sistem Informasi',
      fakultas: json['fakultas']?.toString() ?? 'Teknologi Informasi',
      ipk: double.tryParse(json['ipk']?.toString() ?? '0.00') ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengguna': idPengguna,
        'deskripsi_singkat': deskripsiSingkat,
        'kontak': kontak,
        'program_studi': programStudi,
        'fakultas': fakultas,
        'ipk': ipk,
      };
}
