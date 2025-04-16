import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tugas_absen/services/attendance_service.dart';
import 'package:geocoding/geocoding.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng userLocation = const LatLng(0, 0);
  bool isInsideArea = false;

  // Lokasi titik absen, ganti sesuai kebutuhan
  final LatLng checkInLocation = const LatLng(
    -6.21090,
    106.812946,
  ); // contoh: Jakarta
  final double allowedRadius = 40.0; // dalam meter

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLocation();
  }

  Future<void> _checkPermissionAndLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi diperlukan untuk Check In');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      isInsideArea = _checkDistance(position);
    });

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 16));
  }

  bool _checkDistance(Position position) {
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      checkInLocation.latitude,
      checkInLocation.longitude,
    );
    return distance <= allowedRadius;
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

  void _handleCheckIn() async {
    if (isInsideArea) {
      final lat = userLocation.latitude;
      final lng = userLocation.longitude;
      final address = await _getAddressFromCoordinates(lat, lng);

      bool success = await AttendanceService.checkIn(lat, lng, address);

      if (success) {
        Navigator.pop(context); // Atau Get.back();
      }
    } else {
      Get.snackbar('Gagal', 'Kamu berada di luar area check-in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Check In", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Lokasi Anda",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: checkInLocation,
                    zoom: 16,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("checkin_location"),
                      position: checkInLocation,
                      infoWindow: const InfoWindow(title: "Titik Absen"),
                    ),
                    if (userLocation.latitude != 0 &&
                        userLocation.longitude != 0)
                      Marker(
                        markerId: const MarkerId("your_location"),
                        position: userLocation,
                        infoWindow: const InfoWindow(title: "Lokasi Kamu"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId("checkin_radius"),
                      center: checkInLocation,
                      radius: allowedRadius, // 100 meter
                      fillColor: Colors.purple.withOpacity(0.2),
                      strokeColor: Colors.deepPurple,
                      strokeWidth: 2,
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleCheckIn,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Check In Sekarang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
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
