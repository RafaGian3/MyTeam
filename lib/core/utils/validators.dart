/// Helper validasi input form aplikasi MyTeam
class Validators {
  static String? validateNim(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIM wajib diisi';
    }
    if (value.trim().length < 8) {
      return 'NIM minimal 8 karakter';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? validateMinLength(String? value, String fieldName, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (value.trim().length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  static String? validateIpk(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IPK wajib diisi';
    }
    final ipk = double.tryParse(value.trim());
    if (ipk == null) {
      return 'IPK harus berupa angka desimal (contoh: 3.75)';
    }
    if (ipk < 0.0 || ipk > 4.0) {
      return 'Nilai IPK harus berada pada rentang 0.00 hingga 4.00';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor kontak / WhatsApp wajib diisi';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(08|\+628|628)[0-9]{8,13}$').hasMatch(cleaned)) {
      return 'Format nomor tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tautan URL wajib diisi';
    }
    final trimmed = value.trim();
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(trimmed)) {
      return 'Format tautan URL tidak valid (contoh: https://linkedin.com/in/...)';
    }
    return null;
  }

  static String? validateTahun(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tahun kegiatan wajib diisi';
    }
    final tahun = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;
    if (tahun == null) {
      return 'Tahun harus berupa 4 digit angka';
    }
    if (tahun < 2015 || tahun > currentYear + 1) {
      return 'Tahun harus antara 2015 hingga ${currentYear + 1}';
    }
    return null;
  }
}
