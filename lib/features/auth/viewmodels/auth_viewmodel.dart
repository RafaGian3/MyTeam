import 'package:flutter/material.dart';
import '../models/auth_user_model.dart';
import '../services/auth_service.dart';

/// ViewModel untuk mengelola state autentikasi (MVVM)
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AuthUserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;

  Future<bool> login(String nim, String kataSandi) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.login(nim: nim, kataSandi: kataSandi);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nim,
    required String namaPengguna,
    required String kataSandi,
    required String kataSandiKonfirmasi,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.register(
        nim: nim,
        namaPengguna: namaPengguna,
        kataSandi: kataSandi,
        kataSandiKonfirmasi: kataSandiKonfirmasi,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
