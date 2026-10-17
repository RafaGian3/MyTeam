import '../../auth/models/auth_user_model.dart';
import 'data_diri_model.dart';
import 'media_sosial_model.dart';
import 'minat_model.dart';
import 'keahlian_model.dart';
import 'pengalaman_model.dart';
import 'tim_diikuti_model.dart';

/// Model Agregasi Detail Profil Lengkap Mahasiswa (FR-01 s/d FR-06)
class ProfileDetailModel {
  final AuthUserModel pengguna;
  final DataDiriModel? dataDiri;
  final List<MediaSosialModel> mediaSosial;
  final List<MinatModel> minat;
  final List<KeahlianModel> keahlian;
  final List<PengalamanModel> pengalaman;
  final List<TimDiikutiModel> timDiikuti;

  const ProfileDetailModel({
    required this.pengguna,
    this.dataDiri,
    this.mediaSosial = const [],
    this.minat = const [],
    this.keahlian = const [],
    this.pengalaman = const [],
    this.timDiikuti = const [],
  });

  factory ProfileDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final userJson = data['pengguna'] as Map<String, dynamic>? ?? {};
    final user = AuthUserModel(
      idPengguna: userJson['id_pengguna']?.toString() ?? '',
      nim: userJson['nim']?.toString() ?? '',
      namaPengguna: userJson['nama_pengguna']?.toString() ?? '',
      fotoProfil: userJson['foto_profil']?.toString(),
      token: '',
    );

    final dataDiriJson = data['data_diri'] as Map<String, dynamic>?;
    final dataDiri = dataDiriJson != null ? DataDiriModel.fromJson(dataDiriJson) : null;

    final medsosList = (data['media_sosial'] as List<dynamic>? ?? [])
        .map((e) => MediaSosialModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final minatList = (data['minat'] as List<dynamic>? ?? [])
        .map((e) => MinatModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final keahlianList = (data['keahlian'] as List<dynamic>? ?? [])
        .map((e) => KeahlianModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pengalamanList = (data['pengalaman'] as List<dynamic>? ?? [])
        .map((e) => PengalamanModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final timList = (data['tim_yang_diikuti'] as List<dynamic>? ?? [])
        .map((e) => TimDiikutiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProfileDetailModel(
      pengguna: user,
      dataDiri: dataDiri,
      mediaSosial: medsosList,
      minat: minatList,
      keahlian: keahlianList,
      pengalaman: pengalamanList,
      timDiikuti: timList,
    );
  }
}
