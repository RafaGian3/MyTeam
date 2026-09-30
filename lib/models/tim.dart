/// Model tim (mengacu ke tabel data_tim).
class Tim {
  final String id;
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String deskripsi;
  final String statusTim;

  const Tim({
    required this.id,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.deskripsi,
    required this.statusTim,
  });
}
