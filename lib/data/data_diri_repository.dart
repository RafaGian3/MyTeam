import '../models/data_diri.dart';

// FR-01: Repository in-memory untuk CRUD data diri pengguna
// Pola konsisten dengan TeamRepository yang sudah ada
class DataDiriRepository {
  // Penyimpanan in-memory: key = idPengguna
  final Map<String, DataDiri> _store = {};

  /// Ambil data diri berdasarkan ID pengguna
  Future<DataDiri?> getDataDiri(String idPengguna) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _store[idPengguna];
  }

  /// Simpan (create) data diri baru
  Future<DataDiri> saveDataDiri(DataDiri dataDiri) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _store[dataDiri.idPengguna] = dataDiri;
    return dataDiri;
  }

  /// Perbarui (update) data diri yang sudah ada
  Future<DataDiri> updateDataDiri(DataDiri dataDiri) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_store.containsKey(dataDiri.idPengguna)) {
      throw Exception('Data diri tidak ditemukan untuk diperbarui.');
    }
    _store[dataDiri.idPengguna] = dataDiri;
    return dataDiri;
  }

  /// Hapus data diri berdasarkan ID pengguna
  Future<void> deleteDataDiri(String idPengguna) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_store.containsKey(idPengguna)) {
      throw Exception('Data diri tidak ditemukan.');
    }
    _store.remove(idPengguna);
  }
}
