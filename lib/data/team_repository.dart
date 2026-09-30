import '../models/team.dart';

class TeamRepository {
  // Data dummy tim yang relevan dengan aplikasi MyTeam Mahasiswa Unand
  final List<Team> _dummyTeams = const [
    Team(
      id: 'team-001',
      name: 'Inovasi PKM-KC Unand',
      activity: 'Pekan Ilmiah Mahasiswa Nasional (PIMNAS 2026)',
      description:
          'Pengembangan sistem sensor IoT berbasis AI untuk monitoring kelembapan tanah pertanian lokal di Sumatera Barat.',
      category: 'PKM-KC',
      requiredSkills: ['IoT Engineer', 'Mobile Dev'],
      openPositions: 2,
      capacity: 4,
      members: 2,
    ),
    Team(
      id: 'team-002',
      name: 'Fintech Hackathon Syariah',
      activity: 'Kompetisi Nasional BSI Hackathon',
      description:
          'Proyek aplikasi dompet digital syariah berbasis transparansi akad zakat dan wakaf untuk UMKM Padang.',
      category: 'Competition',
      requiredSkills: ['UI/UX Designer', 'Backend Dev'],
      openPositions: 1,
      capacity: 4,
      members: 3,
      isBlue: true,
    ),
    Team(
      id: 'team-003',
      name: 'Tim Penelitian NLP Bahasa Minang',
      activity: 'Riset Mandiri Laboratorium AI Unand',
      description:
          'Proyek translasi otomatis Bahasa Minang ke Bahasa Indonesia menggunakan model Machine Learning.',
      category: 'Penelitian',
      requiredSkills: ['Python', 'NLP', 'Data Science'],
      openPositions: 2,
      capacity: 5,
      members: 3,
    ),
    Team(
      id: 'team-004',
      name: 'Portal Kampus Mobile Unand',
      activity: 'Proyek Tugas Akhir & Portfolio',
      description:
          'Aplikasi Flutter terintegrasi untuk portal jadwal kuliah, denah kampus, dan info kegiatan mahasiswa.',
      category: 'Proyek',
      requiredSkills: ['Flutter', 'State Management', 'Figma'],
      openPositions: 3,
      capacity: 6,
      members: 3,
      isBlue: true,
    ),
  ];

  /// Mengambil daftar tim secara asynchronous dengan simulasi loading & opsi simulasikan error
  Future<List<Team>> fetchTeams({bool shouldFail = false}) async {
    // Simulasi waktu tunggu server/network (1.5 detik)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulasi penanganan error (akan berguna untuk Langkah 5)
    if (shouldFail) {
      throw Exception('Gagal memuat data tim. Periksa koneksi internet Anda.');
    }

    return _dummyTeams;
  }

  /// Mengambil detail tim berdasarkan ID secara asynchronous
  Future<Team?> getTeamById(String id, {bool shouldFail = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (shouldFail) {
      throw Exception('Gagal mengambil detail tim.');
    }

    try {
      return _dummyTeams.firstWhere((team) => team.id == id);
    } catch (_) {
      return null;
    }
  }
}
