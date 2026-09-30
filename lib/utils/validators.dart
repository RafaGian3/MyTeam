class Validators {
  // [BARU]
  const Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    // [BARU]
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int length, {
    String fieldName = 'Field',
  }) {
    // [BARU]
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < length) {
      return '$fieldName minimal $length karakter';
    }
    return null;
  }

  static String? email(String? value) {
    // [BARU]
    final requiredError = requiredField(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    // [BARU]
    final requiredError = requiredField(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }
}
