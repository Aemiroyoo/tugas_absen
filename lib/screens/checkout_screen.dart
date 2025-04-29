import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // untuk menampilkan peta
import 'package:geolocator/geolocator.dart'; // untuk mendapatkan lokasi pengguna
import 'package:get/get.dart'; // untuk menampilkan snackbar
import 'package:tugas_absen/services/attendance_service.dart'; // untuk mengirim data ke server
import 'package:geocoding/geocoding.dart'; // untuk mendapatkan alamat dari koordinat

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng userLocation = const LatLng(0, 0);
  bool isInsideArea = false;
  bool isLoading = false;
  String? currentAddress;

  // Lokasi titik absen, ganti sesuai kebutuhan
  final LatLng checkOutLocation = const LatLng(
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
    setState(() {
      isLoading = true;
    });

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Error',
        'Izin lokasi diperlukan untuk Check Out',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final address = await _getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      isInsideArea = _checkDistance(position);
      currentAddress = address;
      isLoading = false;
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
    setState(() {
      isLoading = true;
    });

    if (isInsideArea) {
      final lat = userLocation.latitude;
      final lng = userLocation.longitude;
      final address = await _getAddressFromCoordinates(lat, lng);

      bool success = await AttendanceService.checkOut(lat, lng, address);

      if (success) {
        Get.back(result: true);
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat check out',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          icon: const Icon(Icons.error_outline, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Perhatian',
        'Kamu berada di luar area check-out. Mohon mendekat ke lokasi absensi.',
        backgroundColor: Colors.amber.shade50,
        colorText: Colors.amber.shade900,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6A3DE8),
              size: 22,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Map as full background
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: checkOutLocation,
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId("checkout_location"),
                position: checkOutLocation,
                infoWindow: const InfoWindow(title: "Titik Check Out"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
              if (userLocation.latitude != 0 && userLocation.longitude != 0)
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
                circleId: const CircleId("checkout_radius"),
                center: checkOutLocation,
                radius: allowedRadius,
                fillColor: const Color(0xFF6A3DE8).withOpacity(0.2),
                strokeColor: const Color(0xFF6A3DE8).withOpacity(0.8),
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),

          // Top Gradient for better visibility of app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content area at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEFE7FF),
                        radius: 22,
                        child: Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF6A3DE8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lokasi Anda",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130,
                            child: Text(
                              currentAddress ?? "Memuat lokasi...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isInsideArea
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isInsideArea
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isInsideArea
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInsideArea
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            color: isInsideArea ? Colors.green : Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isInsideArea ? "Lokasi Valid" : "Di Luar Area",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      isInsideArea
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isInsideArea
                                    ? "Anda berada dalam jangkauan area check-out"
                                    : "Anda berada di luar area check-out yang ditentukan",
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isInsideArea
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Check Out button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleCheckOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF6A3DE8).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout_rounded, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Check Out Sekarang",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Floating action buttons for map controls
          Positioned(
            right: 16,
            bottom: 340,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF6A3DE8)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Color(0xFF6A3DE8)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "myLocation",
                  onPressed: () async {
                    if (userLocation.latitude != 0 &&
                        userLocation.longitude != 0) {
                      final controller = await _controller.future;
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(userLocation, 16),
                      );
                    } else {
                      _checkPermissionAndLocation();
                    }
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF6A3DE8),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Color(0xFF6A3DE8),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
