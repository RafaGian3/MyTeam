import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../models/profile_detail_model.dart';
import '../services/profile_service.dart';

/// ViewModel untuk mengelola state dan logika bisnis fitur Profil Mahasiswa (MVVM)
class ProfileViewModel extends ChangeNotifier {
  bool _isLoading = true;
  String? _errorMessage;
  ProfileDetailModel? _profile;
  String _currentUserId = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileDetailModel? get profile => _profile;
  String get currentUserId => _currentUserId;

  Future<void> loadProfile({String? idPenggunaOverride}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionUserId = await StorageService.getUserId() ?? 'usr_fuadi_01';
      _currentUserId = idPenggunaOverride ?? sessionUserId;

      _profile = await ProfileService.getProfileDetail(_currentUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // FR-01
  Future<bool> updateDataDiri({
    required String deskripsiSingkat,
    required String kontak,
    required String programStudi,
    required String fakultas,
    required double ipk,
  }) async {
    final success = await ProfileService.updateDataDiri(
      idPengguna: _currentUserId,
      deskripsiSingkat: deskripsiSingkat,
      kontak: kontak,
      programStudi: programStudi,
      fakultas: fakultas,
      ipk: ipk,
    );
    if (success) await loadProfile();
    return success;
  }

  // Update Foto (Preset Avatar)
  Future<bool> updateFotoProfil(String fotoUrl) async {
    final success = await ProfileService.updateFotoProfil(
      idPengguna: _currentUserId,
      fotoUrl: fotoUrl,
    );
    if (success) await loadProfile();
    return success;
  }

  // Upload Foto Berkas (Kamera / Galeri)
  Future<bool> uploadFotoProfilFile(String filePath) async {
    try {
      final fotoUrl = await ProfileService.uploadFotoProfilFile(
        filePath: filePath,
        idPengguna: _currentUserId,
      );
      if (fotoUrl != null) {
        await loadProfile();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // FR-02: Medsos
  Future<bool> addMediaSosial(String nama, String link) async {
    final success = await ProfileService.addMediaSosial(
      idPengguna: _currentUserId,
      namaMediaSosial: nama,
      linkMediaSosial: link,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> updateMediaSosial(String id, String nama, String link) async {
    final success = await ProfileService.updateMediaSosial(
      idMediaSosial: id,
      namaMediaSosial: nama,
      linkMediaSosial: link,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> deleteMediaSosial(String id) async {
    final success = await ProfileService.deleteMediaSosial(id);
    if (success) await loadProfile();
    return success;
  }

  // FR-03: Minat
  Future<bool> addMinat(String minat, String desc) async {
    final success = await ProfileService.addMinat(
      idPengguna: _currentUserId,
      minat: minat,
      deskripsiMinat: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> updateMinat(String id, String minat, String desc) async {
    final success = await ProfileService.updateMinat(
      idMinat: id,
      minat: minat,
      deskripsiMinat: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> deleteMinat(String id) async {
    final success = await ProfileService.deleteMinat(id);
    if (success) await loadProfile();
    return success;
  }

  // FR-04: Keahlian
  Future<bool> addKeahlian(String keahlian, String desc) async {
    final success = await ProfileService.addKeahlian(
      idPengguna: _currentUserId,
      keahlian: keahlian,
      deskripsiKeahlian: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> updateKeahlian(String id, String keahlian, String desc) async {
    final success = await ProfileService.updateKeahlian(
      idKeahlian: id,
      keahlian: keahlian,
      deskripsiKeahlian: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> deleteKeahlian(String id) async {
    final success = await ProfileService.deleteKeahlian(id);
    if (success) await loadProfile();
    return success;
  }

  // FR-05: Pengalaman
  Future<bool> addPengalaman(String kegiatan, String peran, int tahun, String desc) async {
    final success = await ProfileService.addPengalaman(
      idPengguna: _currentUserId,
      namaKegiatan: kegiatan,
      peran: peran,
      tahun: tahun,
      deskripsiPengalaman: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> updatePengalaman(String id, String kegiatan, String peran, int tahun, String desc) async {
    final success = await ProfileService.updatePengalaman(
      idPengalaman: id,
      namaKegiatan: kegiatan,
      peran: peran,
      tahun: tahun,
      deskripsiPengalaman: desc,
    );
    if (success) await loadProfile();
    return success;
  }

  Future<bool> deletePengalaman(String id) async {
    final success = await ProfileService.deletePengalaman(id);
    if (success) await loadProfile();
    return success;
  }
}
