import 'package:flutter/foundation.dart';

import '../data/data_diri_repository.dart'; // FR-01
import '../models/data_diri.dart'; // FR-01
import '../models/team.dart';

class AppProvider extends ChangeNotifier {
  bool isLoginMode = true;
  bool isPasswordVisible = false;
  int selectedTab = 0;
  String searchQuery = '';
  String selectedCategory = 'Semua';

  // FR-01: ID pengguna yang sedang login (hardcode sementara, belum ada auth)
  final String idPengguna = 'user-2411522001';

  // FR-01: Repository data diri
  final DataDiriRepository dataDiriRepository = DataDiriRepository();

  // FR-01: Data diri pengguna yang sedang login
  DataDiri? dataDiri;

  // FR-01: Set data diri (dipanggil setelah load/save dari screen)
  void setDataDiri(DataDiri? value) {
    dataDiri = value;
    notifyListeners();
  }

  // FR-01: Hapus data diri dari state (dipanggil setelah delete berhasil)
  void clearDataDiri() {
    dataDiri = null;
    notifyListeners();
  }

  // FR-01: Logout — reset state ke awal
  void logout() {
    isLoginMode = true;
    isPasswordVisible = false;
    selectedTab = 0;
    searchQuery = '';
    selectedCategory = 'Semua';
    dataDiri = null;
    notifyListeners();
  }

  final List<Team> teams = const [
    Team(
      name: 'Inovasi PKM-KC Unand',
      activity: 'Pekan Ilmiah Mahasiswa Nasional (PIMNAS 2026)',
      category: 'PKM-KC',
      requiredSkills: ['IoT Engineer', 'Mobile Dev'],
      openPositions: 2,
      capacity: 4,
      members: 2,
    ),
    Team(
      name: 'Fintech Hackathon Syariah',
      activity: 'Kompetisi Nasional BSI Hackathon',
      category: 'Competition',
      requiredSkills: ['UI/UX Designer (1)'],
      openPositions: 1,
      capacity: 4,
      members: 3,
      isBlue: true,
    ),
  ];

  final List<StudentTalent> talents = const [
    StudentTalent(
      name: 'Aisyah Putri',
      major: "Teknik Informatika '23",
      skills: ['UI/UX', 'Figma', 'Prototyping'],
      avatarLabel: 'AP',
    ),
    StudentTalent(
      name: 'Rian Pratama',
      major: "Sistem Informasi '22",
      skills: ['React Native', 'Firebase'],
      avatarLabel: 'RP',
    ),
  ];

  void toggleAuthMode(bool login) {
    isLoginMode = login;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setSelectedTab(int value) {
    selectedTab = value;
    notifyListeners();
  }

  List<Team> get filteredTeams {
    final query = searchQuery.trim().toLowerCase();
    return teams.where((team) {
      final matchesCategory = selectedCategory == 'Semua' ||
          team.categoryLabel == selectedCategory ||
          team.category == selectedCategory;
      final matchesQuery = query.isEmpty ||
          '${team.name} ${team.activity} ${team.requiredSkills.join(' ')}'
              .toLowerCase()
              .contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
