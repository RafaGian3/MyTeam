class Team {
  const Team({
    required this.name,
    required this.activity,
    required this.category,
    required this.requiredSkills,
    required this.openPositions,
    required this.capacity,
    required this.members,
    this.isBlue = false,
  });

  final String name;
  final String activity;
  final String category;
  final List<String> requiredSkills;
  final int openPositions;
  final int capacity;
  final int members;
  final bool isBlue;

  String get categoryLabel => category == 'Competition' ? 'Lomba' : category;
}

class StudentTalent {
  const StudentTalent({
    required this.name,
    required this.major,
    required this.skills,
    required this.avatarLabel,
  });

  final String name;
  final String major;
  final List<String> skills;
  final String avatarLabel;
}
