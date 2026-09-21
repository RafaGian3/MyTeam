import 'package:flutter/foundation.dart';

import '../models/team.dart';

class AppProvider extends ChangeNotifier {
  bool isLoginMode = true;
  bool isPasswordVisible = false;
  int selectedTab = 0;
  String searchQuery = '';
  String selectedCategory = 'Semua';

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
