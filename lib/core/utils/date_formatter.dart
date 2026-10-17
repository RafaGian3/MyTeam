/// Helper pemformatan tanggal dan waktu
class DateFormatter {
  static const List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static String formatTanggal(DateTime dateTime) {
    return '${dateTime.day} ${_namaBulan[dateTime.month - 1]} ${dateTime.year}';
  }

  static String formatRelatif(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit yang lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return formatTanggal(dateTime);
  }
}
