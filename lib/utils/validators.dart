class Validators {
  /// Validasi bidang wajib diisi
  static String? requiredField(String? value, [String fieldName = 'Bidang ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi format email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi kata sandi
  static String? password(String? value, [int minLength = 6]) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < minLength) {
      return 'Kata sandi minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi panjang minimal karakter
  static String? minLength(String? value, int min, [String fieldName = 'Input']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Validasi nilai rating (angka 1 hingga 5)
  static String? rating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rating tidak boleh kosong';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 5) {
      return 'Rating harus berupa angka antara 1 hingga 5';
    }
    return null;
  }
}
