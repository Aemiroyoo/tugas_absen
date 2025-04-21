import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tugas_absen/screens/checkin_screen.dart';
import 'package:tugas_absen/screens/checkout_screen.dart';
import 'package:tugas_absen/screens/permission_screen.dart';
import 'package:tugas_absen/services/attendance_service.dart';
import 'package:tugas_absen/services/auth_service.dart';

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
    _handleRefresh();
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

  Future<void> _handleRefresh() async {
    await _loadUserName();
    await _loadAbsenceTimes();
  }

  Future<void> _loadUserName() async {
    final data = await AuthService.getProfile();
    if (data != null) {
      setState(() {
        userName = data['name'] ?? 'User';
      });
    } else {
      setState(() {
        userName = 'User';
      });
    }
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
          checkInTime = _formatTime(todayRecord['check_in']);
          checkOutTime = _formatTime(todayRecord['check_out']);
        });
      }
    }
  }

  String _formatTime(dynamic dateTimeString) {
    if (dateTimeString == null) return '-- : --';
    try {
      final dt = DateTime.parse(dateTimeString);
      final formatted = DateFormat(
        'hh:mm a',
      ).format(dt); // 🔥 12-hour format + AM/PM
      return formatted;
    } catch (e) {
      return '-- : --';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6), // Background ungu tetap
      body: SafeArea(
        child: Column(
          children: [
            // Header Home Page
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                children: const [
                  Text(
                    'Home Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Area scroll putih
            Expanded(
              child: Container(
                // margin: const EdgeInsets.only(top: 16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Card Profile dan Jam
                          Container(
                            // margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: Color(0xFF8656D6),
                                      ), // ungu
                                    ),

                                    const SizedBox(width: 12),
                                    Text(
                                      'Hi, $userName :)',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Column(
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 000,
                                        ),
                                        child: Text(
                                          DateFormat('hh:mm:ss a').format(_now),
                                          key: ValueKey(_now.second),
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'RobotoMono',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        DateFormat(
                                          'EEEE, dd MMMM yyyy',
                                        ).format(_now),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Check In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Chip(
                                          label: Text(
                                            checkInTime ?? '-- : --',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
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
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Chip(
                                          label: Text(
                                            checkOutTime ?? '-- : --',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
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
                          // Grid Menu
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              buildMenuItem(
                                'Check In',
                                Icons.login_rounded,
                                () async {
                                  final result = await Get.to(
                                    () => const CheckInScreen(),
                                  );
                                  if (result == true) {
                                    _handleRefresh();
                                  }
                                },
                              ),
                              buildMenuItem(
                                'Check Out',
                                Icons.logout_rounded,
                                () async {
                                  final result = await Get.to(
                                    () => const CheckOutScreen(),
                                  );
                                  if (result == true) {
                                    _handleRefresh();
                                  }
                                },
                              ),
                              buildMenuItem(
                                'Ajukan Izin',
                                Icons.assignment_turned_in_rounded,
                                () {
                                  Get.to(() => const PermissionScreen());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
