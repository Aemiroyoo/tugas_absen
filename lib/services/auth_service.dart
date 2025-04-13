import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://absen.quidi.id/api';

  // REGISTER
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Registrasi berhasil!');
        return true;
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar('Gagal', body['message'] ?? 'Registrasi gagal');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
      return false;
    }
  }

  // LOGIN
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // Simpan token

        Get.snackbar('Berhasil', 'Login berhasil!');
        return true;
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar('Gagal', body['message'] ?? 'Login gagal');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.snackbar('Keluar', 'Kamu telah logout.');
  }

  // CEK LOGIN STATUS
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
