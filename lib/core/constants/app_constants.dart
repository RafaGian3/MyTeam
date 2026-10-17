/// Konstanta aplikasi dan enumerasi nilai terbatas (Acuan: PRD v1.0)
class AppConstants {
  static const String appName = 'MyTeam';
  static const String appTagline = 'Aplikasi Pencarian & Pembentukan Tim Mahasiswa Unand';

  // Kategori Kegiatan Tim
  static const List<String> kategoriKegiatan = [
    'Semua',
    'Lomba',
    'Penelitian',
    'Proyek',
    'Lainnya',
  ];

  // Status Tim
  static const String statusTimTerbuka = 'terbuka';
  static const String statusTimDitutup = 'ditutup';

  // Status Pengajuan / Undangan
  static const String statusMenunggu = 'menunggu';
  static const String statusDiterima = 'diterima';
  static const String statusDitolak = 'ditolak';

  // Jenis Dokumen Pendukung
  static const String docPoster = 'poster';
  static const String docPanduan = 'panduan';

  // Jenis Notifikasi
  static const String notifRiwayatDiri = 'riwayat_diri_diperbarui';
  static const String notifPengajuanMasuk = 'pengajuan_masuk';
  static const String notifPengajuanDiterima = 'pengajuan_diterima';
  static const String notifPengajuanDitolak = 'pengajuan_ditolak';
}
