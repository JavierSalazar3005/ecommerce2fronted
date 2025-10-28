import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_response.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  AuthResponse? _authResponse;
  bool _isLoading = false;

  AuthProvider(this._apiService) {
    _loadAuthData();
  }

  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authResponse != null;
  Role? get userRole => _authResponse?.role;
  int? get userId => _authResponse?.userId;

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('authData');
    
    if (authData != null) {
      try {
        _authResponse = AuthResponse.fromJson(jsonDecode(authData));
        _apiService.setToken(_authResponse!.token);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading auth data: $e');
      }
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_authResponse != null) {
      await prefs.setString('authData', jsonEncode(_authResponse!.toJson()));
    } else {
      await prefs.remove('authData');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required Role role,
    String? companyName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _authResponse = await _apiService.register(
        email: email,
        password: password,
        role: role,
        companyName: companyName,
      );
      _apiService.setToken(_authResponse!.token);
      await _saveAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _authResponse = await _apiService.login(
        email: email,
        password: password,
      );
      _apiService.setToken(_authResponse!.token);
      await _saveAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _authResponse = null;
    _apiService.setToken(null);
    await _saveAuthData();
    notifyListeners();
  }
}
