import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// ============================
  /// CHECK AUTH (APP START)
  /// ============================
  /// ❌ TANPA loading
  /// ❌ TANPA notifyListeners di awal
  Future<void> checkAuthStatus() async {
    try {
      final user = await AuthService.getUser();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners(); // aman (dipanggil SETELAH await)
  }

  /// ============================
  /// LOGIN
  /// ============================
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);

      if (response['status'] == 1) {
        _user = User.fromJson(response['user']);
        await AuthService.saveUser(_user!);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ============================
  /// REGISTER
  /// ============================
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await ApiService.register(username, email, password);

      if (response['status'] == 1) {
        _user = User.fromJson(response['user']);
        await AuthService.saveUser(_user!);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ============================
  /// CLEAR ERROR
  /// ============================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
