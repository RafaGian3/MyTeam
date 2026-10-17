import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team_model.dart';

/// Model data draf pembuatan tim lokal (Multi-Draft support)
class TeamDraftModel {
  final String idDraft;
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String deskripsi;
  final List<KebutuhanTimModel> kebutuhan;
  final DateTime savedAt;

  const TeamDraftModel({
    required this.idDraft,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.deskripsi,
    required this.kebutuhan,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'idDraft': idDraft,
        'namaTim': namaTim,
        'namaKegiatan': namaKegiatan,
        'kategoriKegiatan': kategoriKegiatan,
        'deskripsi': deskripsi,
        'kebutuhan': kebutuhan.map((k) => k.toJson()).toList(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory TeamDraftModel.fromJson(Map<String, dynamic> json) => TeamDraftModel(
        idDraft: json['idDraft']?.toString() ??
            'draft_${DateTime.now().millisecondsSinceEpoch}',
        namaTim: json['namaTim']?.toString() ?? '',
        namaKegiatan: json['namaKegiatan']?.toString() ?? '',
        kategoriKegiatan: json['kategoriKegiatan']?.toString() ?? 'Lomba',
        deskripsi: json['deskripsi']?.toString() ?? '',
        kebutuhan: (json['kebutuhan'] as List<dynamic>?)
                ?.map((k) =>
                    KebutuhanTimModel.fromJson(k as Map<String, dynamic>))
                .toList() ??
            const [],
        savedAt: json['savedAt'] != null
            ? DateTime.tryParse(json['savedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  bool get isEmpty =>
      namaTim.trim().isEmpty &&
      namaKegiatan.trim().isEmpty &&
      deskripsi.trim().isEmpty &&
      (kebutuhan.isEmpty ||
          kebutuhan.every((k) => k.posisiDibutuhkan.trim().isEmpty));

  TeamDraftModel copyWith({
    String? idDraft,
    String? namaTim,
    String? namaKegiatan,
    String? kategoriKegiatan,
    String? deskripsi,
    List<KebutuhanTimModel>? kebutuhan,
    DateTime? savedAt,
  }) {
    return TeamDraftModel(
      idDraft: idDraft ?? this.idDraft,
      namaTim: namaTim ?? this.namaTim,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      kategoriKegiatan: kategoriKegiatan ?? this.kategoriKegiatan,
      deskripsi: deskripsi ?? this.deskripsi,
      kebutuhan: kebutuhan ?? this.kebutuhan,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

/// Service untuk mengelola multi-draf formulir tim secara offline/lokal
class TeamDraftService {
  static const String _keyListDrafts = 'myteam_team_creation_drafts_list';
  static const String _legacySingleKey = 'myteam_team_creation_draft';

  /// Mengambil semua daftar draf yang tersimpan (diurutkan dari yang terbaru)
  static Future<List<TeamDraftModel>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();

    // Migrasi otomatis jika sebelumnya ada single draft lama
    final legacyStr = prefs.getString(_legacySingleKey);
    if (legacyStr != null && legacyStr.isNotEmpty) {
      try {
        final legacyMap = jsonDecode(legacyStr) as Map<String, dynamic>;
        final legacyDraft = TeamDraftModel.fromJson(legacyMap);
        await prefs.remove(_legacySingleKey);
        await saveDraft(legacyDraft);
      } catch (_) {}
    }

    final raw = prefs.getString(_keyListDrafts);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final drafts = list
          .map((item) => TeamDraftModel.fromJson(item as Map<String, dynamic>))
          .where((d) => !d.isEmpty)
          .toList();

      drafts.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return drafts;
    } catch (_) {
      return [];
    }
  }

  /// Mengambil 1 draf berdasarkan ID
  static Future<TeamDraftModel?> getDraftById(String idDraft) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d.idDraft == idDraft);
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan atau memperbarui draf dalam list
  static Future<void> saveDraft(TeamDraftModel draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();

    final existingIndex = drafts.indexWhere((d) => d.idDraft == draft.idDraft);
    if (existingIndex >= 0) {
      drafts[existingIndex] = draft;
    } else {
      drafts.insert(0, draft);
    }

    final encoded = jsonEncode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_keyListDrafts, encoded);
  }

  /// Menghapus 1 draf spesifik berdasarkan ID
  static Future<void> deleteDraft(String idDraft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();
    drafts.removeWhere((d) => d.idDraft == idDraft);

    final encoded = jsonEncode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_keyListDrafts, encoded);
  }

  /// Menghapus seluruh draf
  static Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyListDrafts);
    await prefs.remove(_legacySingleKey);
  }

  /// Mengambil jumlah draf yang ada
  static Future<int> getDraftCount() async {
    final drafts = await getAllDrafts();
    return drafts.length;
  }
}
