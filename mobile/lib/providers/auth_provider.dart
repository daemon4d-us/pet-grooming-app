import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AuthProvider() {
    _apiService.initialize();
  }

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      await _apiService.saveAuthToken(response.token);
      _user = response.user;

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(CreateUserRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.register(request);
      // After registration, automatically log in
      await login(request.email, request.password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _apiService.clearAuthToken();
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    if (!await _apiService.isLoggedIn()) return;

    _setLoading(true);
    try {
      _user = await _apiService.getProfile();
      notifyListeners();
    } catch (e) {
      // If we can't load user, token might be invalid
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}