/// Model data autentikasi pengguna MyTeam (Modul 0)
class AuthUserModel {
  final String idPengguna;
  final String nim;
  final String namaPengguna;
  final String? fotoProfil;
  final String token;

  const AuthUserModel({
    required this.idPengguna,
    required this.nim,
    required this.namaPengguna,
    this.fotoProfil,
    required this.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final pengguna = data['pengguna'] as Map<String, dynamic>?;

    if (pengguna != null) {
      return AuthUserModel(
        idPengguna: pengguna['id_pengguna']?.toString() ?? '',
        nim: pengguna['nim']?.toString() ?? '',
        namaPengguna: pengguna['nama_pengguna']?.toString() ?? '',
        fotoProfil: pengguna['foto_profil']?.toString(),
        token: data['token']?.toString() ?? '',
      );
    }

    return AuthUserModel(
      idPengguna: data['id_pengguna']?.toString() ?? '',
      nim: data['nim']?.toString() ?? '',
      namaPengguna: data['nama_pengguna']?.toString() ?? '',
      fotoProfil: data['foto_profil']?.toString(),
      token: data['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengguna': idPengguna,
        'nim': nim,
        'nama_pengguna': namaPengguna,
        'foto_profil': fotoProfil,
        'token': token,
      };
}
