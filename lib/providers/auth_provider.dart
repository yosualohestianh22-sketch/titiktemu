import 'package:flutter/foundation.dart';
import 'package:titik_temu/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _errorMessage = '';

  // Getter
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;

  // Helper untuk memunculkan loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper untuk menyimpan error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Logika Daftar
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.registerWithEmailAndPassword(name, email, password);
      _setLoading(false);
      return true; // Sukses
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false; // Gagal
    }
  }

  // Logika Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.loginWithEmailAndPassword(email, password);
      _setLoading(false);
      return true; // Sukses
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false; // Gagal
    }
  }

  // Logika Logout
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _setLoading(false);
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile(String name, Uint8List? imageBytes) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.updateProfile(name, imageBytes);
      _setLoading(false);
      notifyListeners(); // Notify profile change
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Update Password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.updatePassword(currentPassword, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}
