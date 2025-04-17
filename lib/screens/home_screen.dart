import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_absen/screens/checkin_screen.dart';
import 'package:tugas_absen/screens/checkout_screen.dart';
import 'package:tugas_absen/screens/permission_screen.dart';
import 'package:tugas_absen/services/attendance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late DateTime _now;
  String? userName = 'User';
  String? checkInTime = '-- : --';
  String? checkOutTime = '-- : --';

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
    _loadUserName();
    _loadAbsenceTimes();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedTime {
    final hours = _now.hour.toString().padLeft(2, '0');
    final minutes = _now.minute.toString().padLeft(2, '0');
    final seconds = _now.second.toString().padLeft(2, '0');
    return '$hours H : $minutes M : $seconds S';
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
    });
  }

  Future<void> _loadAbsenceTimes() async {
    final history = await AttendanceService.getHistory();

    if (history != null && history.isNotEmpty) {
      final today = DateTime.now();

      final todayRecord = history.firstWhereOrNull((record) {
        final recordDate = DateTime.parse(record['created_at']);
        return recordDate.year == today.year &&
            recordDate.month == today.month &&
            recordDate.day == today.day;
      });

      if (todayRecord != null) {
        setState(() {
          checkInTime = todayRecord['check_in_time'] ?? '-- : --';
          checkOutTime = todayRecord['check_out_time'] ?? '-- : --';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Text(
                    'Home Page',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8656D6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hi, $userName :)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Check In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Chip(
                                    label: Text(checkInTime ?? '-- : --'),
                                    backgroundColor: Colors.white,
                                  ),
                                ],
                              ),
                              Container(
                                height: 65,
                                width: 1.5,
                                color: Colors.white54,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Check Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Chip(
                                    label: Text(checkOutTime ?? '-- : --'),
                                    backgroundColor: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => const CheckInScreen()),
                          child: buildMenuItem('Check In'),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const CheckOutScreen()),
                          child: buildMenuItem('Check Out'),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const PermissionScreen()),
                          child: buildMenuItem('Ajukan Izin'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title) {
    return Container(
      width: 155,
      height: 125,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 103, 103, 103),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
