class PlatformUploadFile {
  final String name;
  final List<int> bytes;
  final String? path; // null jika di web
  final String jenis; // 'poster' atau 'panduan'

  const PlatformUploadFile({
    required this.name,
    required this.bytes,
    this.path,
    this.jenis = 'poster',
  });
}
