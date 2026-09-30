import '../models/tim.dart';

/// Sumber data sementara (dummy). Nanti diganti API/database MySQL.
class TimRepository {
  static const List<Tim> _tims = [
    Tim(
      id: '1',
      namaTim: 'Tim Gemastik 2026',
      namaKegiatan: 'Gemastik XIX',
      kategoriKegiatan: 'Lomba',
      deskripsi:
          'Tim untuk lomba pengembangan perangkat lunak. Butuh 2 anggota: UI/UX dan backend.',
      statusTim: 'aktif',
    ),
    Tim(
      id: '2',
      namaTim: 'Panitia Seminar IT',
      namaKegiatan: 'Seminar Nasional Teknologi',
      kategoriKegiatan: 'Kepanitiaan',
      deskripsi: 'Mencari anggota divisi acara dan publikasi.',
      statusTim: 'aktif',
    ),
    Tim(
      id: '3',
      namaTim: 'Riset Machine Learning',
      namaKegiatan: 'Penelitian Dosen',
      kategoriKegiatan: 'Penelitian',
      deskripsi:
          'Tim riset klasifikasi citra. Butuh anggota yang menguasai Python.',
      statusTim: 'aktif',
    ),
  ];

  /// simulateError: true -> sengaja gagal untuk menguji error state.
  Future<List<Tim>> fetchTims({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _tims;
  }
}
