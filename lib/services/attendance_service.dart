import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class AttendanceService {
  static const String baseUrl = 'https://absen.quidi.id/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Check-In
  static Future<bool> checkIn(double lat, double lng) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/absen-masuk');

    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'latitude': lat, 'longitude': lng}),
      );

      if (res.statusCode == 200) {
        Get.snackbar("Check-in", "Berhasil!");
        return true;
      } else {
        final body = jsonDecode(res.body);
        Get.snackbar("Check-in Gagal", body['message'] ?? 'Error');
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  // ✅ Check-Out
  static Future<bool> checkOut(double lat, double lng) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/absen-keluar');

    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'latitude': lat, 'longitude': lng}),
      );

      if (res.statusCode == 200) {
        Get.snackbar("Check-out", "Berhasil!");
        return true;
      } else {
        final body = jsonDecode(res.body);
        Get.snackbar("Check-out Gagal", body['message'] ?? 'Error');
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  // ✅ Get Riwayat Absensi
  static Future<List<dynamic>?> getHistory() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/history-absen');

    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      } else {
        Get.snackbar("Gagal", "Tidak dapat memuat riwayat");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

  // ✅ Get Profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/profile');

    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      } else {
        Get.snackbar("Gagal", "Tidak dapat memuat profil");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }
}
