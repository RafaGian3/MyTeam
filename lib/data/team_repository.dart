import '../models/team.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class TeamRepository {
  static const List<Team> _teams = [
    Team(
      id: '1',
      name: 'Inovasi PKM-KC Unand',
      description:
          'Tim PKM Karsa Cipta yang mengembangkan prototipe perangkat IoT '
          'untuk pemantauan lingkungan kampus. Kami mencari rekan yang '
          'menguasai IoT dan pengembangan aplikasi mobile untuk menyiapkan '
          'proposal dan produk menuju PIMNAS 2026.',
      activity: 'Pekan Ilmiah Mahasiswa Nasional (PIMNAS 2026)',
      category: 'PKM-KC',
      requiredSkills: ['IoT Engineer', 'Mobile Dev'],
      openPositions: 2,
      capacity: 4,
      members: 2,
    ),
    Team(
      id: '2',
      name: 'Fintech Hackathon Syariah',
      description:
          'Tim yang menyiapkan solusi fintech syariah untuk kompetisi BSI '
          'Hackathon. Fokus saat ini adalah merancang antarmuka aplikasi dan '
          'alur pengguna, sehingga dibutuhkan satu UI/UX Designer.',
      activity: 'Kompetisi Nasional BSI Hackathon',
      category: 'Competition',
      requiredSkills: ['UI/UX Designer (1)'],
      openPositions: 1,
      capacity: 4,
      members: 3,
      isBlue: true,
    ),
  ];

  /// Mengambil daftar tim.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Team>> fetchTeams({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _teams;
  }
}
