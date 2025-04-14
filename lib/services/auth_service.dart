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
        headers: {'Accept': 'application/json'},
        body: {'name': name, 'email': email, 'password': password},
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
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('RESPON LOGIN: ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = body['data']['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userName', body['data']['user']['name']);
        await prefs.setString('userEmail', body['data']['user']['email']);

        return {
          'success': true,
          'message': body['message'],
          'user': body['data']['user'], // kalau butuh user info juga
        };
      } else {
        return {'success': false, 'message': body['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // // GET PROFILE
  static Future<Map<String, dynamic>?> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      } else {
        print('Gagal ambil profil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error ambil profil: $e');
      return null;
    }
  }

  // // UPDATE PROFILE
  static Future<bool> updateProfile(String name, String email) async {
    final url = Uri.parse('$baseUrl/profile');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      print('Nama: $name, Email: $email'); // Debugging output
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return true;
      } else {
        print('Gagal update profil: ${response.body}');
        // Tampilkan seluruh response body untuk debugging
        final body = jsonDecode(response.body);
        print('Detail error: ${body['errors']}');
        return false;
      }
    } catch (e) {
      print('Error update profil: $e');
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName'); // tambahkan ini
    await prefs.remove('userEmail'); // dan ini

    Get.snackbar('Keluar', 'Kamu telah logout.');
    Get.offAllNamed('/login'); // Navigasi ke halaman login
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
