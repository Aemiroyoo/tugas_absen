import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tugas_absen/services/attendance_service.dart';
import 'package:geocoding/geocoding.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng userLocation = const LatLng(0, 0);
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLocation();
  }

  Future<void> _checkPermissionAndLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi diperlukan');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 16));
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    } catch (e) {
      return "Alamat tidak diketahui";
    }
  }

  void _submitPermission() async {
    final alasan = _reasonController.text.trim();

    if (alasan.isEmpty) {
      Get.snackbar('Validasi', 'Alasan izin wajib diisi');
      return;
    }

    // 🔥 Tampilkan konfirmasi sebelum kirim
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah Anda yakin ingin mengajukan izin ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya, Ajukan'),
              ),
            ],
          ),
    );

    if (confirm != true) {
      return; // User batal, tidak jadi submit
    }

    // 🔥 Jika user setuju, baru lanjut submit
    final lat = userLocation.latitude;
    final lng = userLocation.longitude;
    final address = await _getAddressFromCoordinates(lat, lng);

    bool success = await AttendanceService.requestIzin(
      lat,
      lng,
      address,
      alasan,
    );
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ajukan Izin", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Lokasi Anda Saat Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: const LatLng(
                      -6.21090,
                      106.812946,
                    ), // default kalau belum ada lokasi
                    zoom: 16,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    if (userLocation.latitude != 0 &&
                        userLocation.longitude != 0)
                      Marker(
                        markerId: const MarkerId("your_location"),
                        position: userLocation,
                        infoWindow: const InfoWindow(title: "Lokasi Anda"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: "Alasan Izin",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submitPermission,
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text("Ajukan Izin"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
