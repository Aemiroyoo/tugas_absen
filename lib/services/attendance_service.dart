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
  static Future<bool> checkIn(double lat, double lng, String address) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/absen/check-in');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'check_in_lat': lat.toString(),
          'check_in_lng': lng.toString(),
          'check_in_address': address,
          'status': 'masuk',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', data['message'] ?? 'Berhasil check-in');
        return true;
      } else if (response.statusCode == 400) {
        Get.snackbar('Info', data['message'] ?? 'Sudah check-in hari ini');
        return false;
      } else {
        Get.snackbar('Error', data['message'] ?? 'Gagal check-in');
        return false;
      }
    } catch (e) {
      Get.snackbar('Kesalahan', 'Terjadi kesalahan: $e');
      return false;
    }
  }

  // ✅ Check-Out
  static Future<bool> checkOut(double lat, double lng, String address) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/absen/check-out');

    try {
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          // 'Content-Type': 'application/json',
        },
        body: {
          'check_out_lat': lat.toString(),
          'check_out_lng': lng.toString(),
          'check_out_location': '$lat, $lng',
          'check_out_address': address,
        },
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

  // ✅ Izin
  static Future<bool> requestIzin(
    double lat,
    double lng,
    String address,
    String alasan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/absen/check-in');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'check_in_lat': lat.toString(),
          'check_in_lng': lng.toString(),
          'check_in_address': address,
          'status': 'izin',
          'alasan_izin': alasan,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', data['message'] ?? 'Izin berhasil diajukan');
        return true;
      } else {
        Get.snackbar('Gagal', data['message'] ?? 'Gagal mengajukan izin');
        return false;
      }
    } catch (e) {
      Get.snackbar('Kesalahan', 'Terjadi kesalahan: $e');
      return false;
    }
  }

  // ✅ Get Riwayat Absensi
  static Future<List<dynamic>?> getHistory() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/absen/history');

    try {
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // 👈 Tambahan opsional
        },
      );

      print("RESPON HISTORY (${res.statusCode}): ${res.body}");
      // Debugging
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['data'] != null && body['data'] is List) {
          return body['data'];
        } else {
          final msg = body['message'] ?? 'Data tidak tersedia.';
          Get.snackbar("Gagal", msg);
          return [];
        }
      } else {
        Get.snackbar("Gagal", "Tidak dapat memuat riwayat (${res.statusCode})");
        return [];
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
      return [];
    }
  }
}
