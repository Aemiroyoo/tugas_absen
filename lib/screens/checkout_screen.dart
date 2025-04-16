import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tugas_absen/services/attendance_service.dart';
import 'package:geocoding/geocoding.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng userLocation = const LatLng(0, 0);
  bool isInsideArea = false;

  final LatLng checkOutLocation = const LatLng(-6.21090, 106.812946);
  final double allowedRadius = 40.0;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLocation();
  }

  Future<void> _checkPermissionAndLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi diperlukan untuk Check Out');
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
      checkOutLocation.latitude,
      checkOutLocation.longitude,
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

  void _handleCheckOut() async {
    if (isInsideArea) {
      final lat = userLocation.latitude;
      final lng = userLocation.longitude;
      final address = await _getAddressFromCoordinates(lat, lng);

      bool success = await AttendanceService.checkOut(lat, lng, address);

      if (success) {
        Navigator.pop(context); // atau Get.back()
      }
    } else {
      Get.snackbar('Gagal', 'Kamu berada di luar area check-out.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Check Out", style: TextStyle(color: Colors.white)),
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
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: userLocation,
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('user'),
                    position: userLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                  ),
                  Marker(
                    markerId: const MarkerId('checkOut'),
                    position: checkOutLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: const InfoWindow(title: 'Titik Check Out'),
                  ),
                },
                circles: {
                  Circle(
                    circleId: const CircleId("checkout_radius"),
                    center: checkOutLocation,
                    radius: allowedRadius, // 50 meter
                    fillColor: Colors.purple.withOpacity(0.2),
                    strokeColor: Colors.deepPurple,
                    strokeWidth: 2,
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Check Out Sekarang"),
              onPressed: _handleCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
