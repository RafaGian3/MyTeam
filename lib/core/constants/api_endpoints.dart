/// Definisi konstanta endpoint API MyTeam Backend (Sesuai API Contract v1.0.0)
class ApiEndpoints {
  // Auth (Modul 0)
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Profile & Data Riwayat Diri (Modul 1 - Fuadi)
  static const String profileDetail = '/profile/detail'; // + /{id_pengguna}
  static const String dataDiri = '/profile/data-diri';
  static const String fotoProfil = '/profile/foto-profil';
  static const String mediaSosial = '/profile/media-sosial';
  static const String minat = '/profile/minat';
  static const String keahlian = '/profile/keahlian';
  static const String pengalaman = '/profile/pengalaman';

  // Team Management (Modul 2 - Nayla)
  static const String teams = '/teams';
  static const String myTeams = '/teams/my-teams';

  // Team Feed & Application (Modul 3 - Rafa)
  static const String feed = '/teams/feed';
  static const String joinTeam = '/applications/join-team';
  static const String myApplications = '/applications/my-applications';
  static String teamApplications(String idTim) => '/teams/$idTim/applications';
  static String joinTeamDetail(String idPengajuan) => '/applications/join-team/$idPengajuan';

  // Talent Search & Invitation (Modul 4 - Diva)
  static const String searchMembers = '/members/search';
  static const String inviteMember = '/applications/invite-member';
  static const String receivedInvitations = '/applications/received-invitations';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
}
