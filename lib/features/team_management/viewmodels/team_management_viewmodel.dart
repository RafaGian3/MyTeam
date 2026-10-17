import 'package:flutter/material.dart';
import '../models/platform_upload_file.dart';
import '../models/team_model.dart';
import '../services/team_management_service.dart';

/// ViewModel Modul 2 — Pembentukan & Manajemen Tim (FR-08, FR-09, FR-10, FR-11)
class TeamManagementViewModel extends ChangeNotifier {
  // State: daftar tim
  bool _isLoadingList = false;
  String? _listError;
  List<TeamModel> _myTeams = [];

  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;
  List<TeamModel> get myTeams => _myTeams;

  // State: detail tim
  bool _isLoadingDetail = false;
  String? _detailError;
  TeamModel? _selectedTeam;

  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;
  TeamModel? get selectedTeam => _selectedTeam;

  // State: form aksi (create, update, delete)
  bool _isSaving = false;
  String? _saveError;

  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  // FR-09: Muat daftar tim
  Future<void> loadMyTeams() async {
    _setListLoading(true);
    try {
      _myTeams = await TeamManagementService.getMyTeams();
    } catch (e) {
      _listError = _clean(e);
    } finally {
      _setListLoading(false);
    }
  }

  // FR-09: Muat detail tim
  Future<void> loadTeamDetail(String idTim) async {
    _setDetailLoading(true);
    try {
      _selectedTeam = await TeamManagementService.getTeamDetail(idTim);
    } catch (e) {
      _detailError = _clean(e);
    } finally {
      _setDetailLoading(false);
    }
  }

  // FR-08: Buat tim baru
  Future<bool> createTeam({
    required String namaTim,
    required String namaKegiatan,
    required String kategoriKegiatan,
    required String deskripsi,
    required List<KebutuhanTimModel> kebutuhan,
    List<PlatformUploadFile>? dokumenFiles,
  }) async {
    _setSaving(true);
    try {
      final newTeam = await TeamManagementService.createTeam(
        namaTim: namaTim,
        namaKegiatan: namaKegiatan,
        kategoriKegiatan: kategoriKegiatan,
        deskripsi: deskripsi,
        kebutuhan: kebutuhan,
        dokumenFiles: dokumenFiles,
      );
      _myTeams = [newTeam, ..._myTeams];
      return true;
    } catch (e) {
      _saveError = _clean(e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // FR-10: Update tim
  Future<bool> updateTeam({
    required String idTim,
    required String namaTim,
    required String namaKegiatan,
    required String deskripsi,
    required String statusTim,
    required List<KebutuhanTimModel> kebutuhan,
    List<PlatformUploadFile>? dokumenFiles,
  }) async {
    _setSaving(true);
    try {
      final updated = await TeamManagementService.updateTeam(
        idTim: idTim,
        namaTim: namaTim,
        namaKegiatan: namaKegiatan,
        deskripsi: deskripsi,
        statusTim: statusTim,
        kebutuhan: kebutuhan,
        dokumenFiles: dokumenFiles,
      );
      _selectedTeam = updated;
      final idx = _myTeams.indexWhere((t) => t.idTim == idTim);
      if (idx != -1) _myTeams[idx] = updated;
      return true;
    } catch (e) {
      _saveError = _clean(e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // FR-11: Hapus tim
  Future<bool> deleteTeam(String idTim) async {
    _setSaving(true);
    try {
      await TeamManagementService.deleteTeam(idTim);
      _myTeams.removeWhere((t) => t.idTim == idTim);
      return true;
    } catch (e) {
      _saveError = _clean(e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  // Private helpers
  void _setListLoading(bool value) {
    _isLoadingList = value;
    if (value) _listError = null;
    notifyListeners();
  }

  void _setDetailLoading(bool value) {
    _isLoadingDetail = value;
    if (value) _detailError = null;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    if (value) _saveError = null;
    notifyListeners();
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
