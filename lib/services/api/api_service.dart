import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.43.51:8000/api';

  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Register
  static Future<http.Response> register(String name, String email, String password, String confirm) {
    final url = Uri.parse('$baseUrl/register');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirm,
      }),
    );
  }

  // Login
  static Future<http.Response> login(String email, String password) {
    final url = Uri.parse('$baseUrl/login');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Get Profile
  static Future<http.Response> fetchProfile() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/user');
    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Logout
  static Future<http.Response> logout() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/logout');
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
