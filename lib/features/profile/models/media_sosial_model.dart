/// FR-02: Media Sosial Mahasiswa
class MediaSosialModel {
  final String idMediaSosial;
  final String? idPengguna;
  final String namaMediaSosial;
  final String linkMediaSosial;

  const MediaSosialModel({
    required this.idMediaSosial,
    this.idPengguna,
    required this.namaMediaSosial,
    required this.linkMediaSosial,
  });

  factory MediaSosialModel.fromJson(Map<String, dynamic> json) {
    return MediaSosialModel(
      idMediaSosial: json['id_media_sosial']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString(),
      namaMediaSosial: json['nama_media_sosial']?.toString() ?? '',
      linkMediaSosial: json['link_media_sosial']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_media_sosial': idMediaSosial,
        'id_pengguna': idPengguna,
        'nama_media_sosial': namaMediaSosial,
        'link_media_sosial': linkMediaSosial,
      };
}
