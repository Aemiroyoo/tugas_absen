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
      final formatted = DateFormat('hh:mm a').format(dt);
      return formatted;
    } catch (e) {
      return '-- : --';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [Color(0xFF6A3DE8), Color(0xFF8656D6)],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Home Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   padding: const EdgeInsets.all(8),
                  //   child: const Icon(
                  //     Icons.notifications_none_rounded,
                  //     color: Colors.white,
                  //     size: 24,
                  //   ),
                  // ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
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
                child: RefreshIndicator(
                  color: const Color(0xFF6A3DE8),
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile and clock card
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B4BDD), Color(0xFF5E35C9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8656D6,
                                  ).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Container(
                                      //   padding: const EdgeInsets.all(2),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     shape: BoxShape.circle,
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: Colors.black.withOpacity(
                                      //           0.1,
                                      //         ),
                                      //         blurRadius: 8,
                                      //         offset: const Offset(0, 2),
                                      //       ),
                                      //     ],
                                      //   ),
                                      //   child: const CircleAvatar(
                                      //     radius: 24,
                                      //     backgroundColor: Colors.white,
                                      //     child: Icon(
                                      //       Icons.person,
                                      //       color: Color(0xFF6A3DE8),
                                      //       size: 26,
                                      //     ),
                                      //   ),
                                      // ),
                                      const SizedBox(width: 35),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hi, $userName ',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Active Now',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Text(
                                              DateFormat(
                                                'hh:mm:ss a',
                                              ).format(_now),
                                              key: ValueKey(_now.second),
                                              style: const TextStyle(
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'RobotoMono',
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat(
                                            'EEEE, dd MMMM yyyy',
                                          ).format(_now),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.login_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Check In',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                checkInTime ?? '-- : --',
                                                style: const TextStyle(
                                                  color: Color(0xFF6A3DE8),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 50,
                                          width: 1.5,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              1,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.logout_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Check Out',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                checkOutTime ?? '-- : --',
                                                style: const TextStyle(
                                                  color: Color(0xFF6A3DE8),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action buttons
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              buildActionItem(
                                'Check In',
                                Icons.login_rounded,
                                const Color(0xFF6A3DE8),
                                () async {
                                  final result = await Get.to(
                                    () => const CheckInScreen(),
                                  );
                                  if (result == true) {
                                    _handleRefresh();
                                  }
                                },
                              ),
                              buildActionItem(
                                'Check Out',
                                Icons.logout_rounded,
                                const Color(0xFF7B4BDD),
                                () async {
                                  final result = await Get.to(
                                    () => const CheckOutScreen(),
                                  );
                                  if (result == true) {
                                    _handleRefresh();
                                  }
                                },
                              ),

                              // buildActionItem(
                              //   'History',
                              //   Icons.history_rounded,
                              //   const Color(0xFF5E35C9),
                              //   () {
                              //     // Keeping the placeholder for future functionality
                              //   },
                              // ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          // Summary section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E0FF),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6A3DE8,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today_rounded,
                                        color: Color(0xFF6A3DE8),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Today's Activity",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatusIndicator(
                                      checkInTime != '-- : --'
                                          ? 'Checked In'
                                          : 'Not Checked In',
                                      checkInTime != '-- : --'
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFF9800),
                                    ),
                                    _buildStatusIndicator(
                                      checkOutTime != '-- : --'
                                          ? 'Checked Out'
                                          : 'Not Checked Out',
                                      checkOutTime != '-- : --'
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFF9800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            status.contains('Not')
                ? Icons.pending_rounded
                : Icons.check_circle_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
