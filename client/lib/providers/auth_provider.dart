import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  // Check for existing session on app start
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    
    if (userId != null && username != null && email != null) {
      _user = User(id: userId, username: username, email: email);
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    print('=== AUTH PROVIDER LOGIN ===');
    print('Email: $email');
    print('Password length: ${password.length}');
    
    _isLoading = true;
    notifyListeners();

    try {
      print('Calling API login...');
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      print('API Response: $response');

      _user = User.fromJson(response['user']);
      print('User created: ${_user?.username}');
      
      // Save user info/token locally if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.id);
      await prefs.setString('username', _user!.username);
      await prefs.setString('email', _user!.email);
      print('User saved to SharedPreferences');
      
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Login process completed');
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });
      // Auto login after register or just redirect to login
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
