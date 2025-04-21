import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/attendance_service.dart'; // Pastikan path sesuai

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String formatDate(String? dateTimeStr) {
    if (dateTimeStr == null) return '-';
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
  }

  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '-';
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                children: const [
                  Text(
                    'History Absensi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Body putih
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: FutureBuilder<List<dynamic>?>(
                  future: AttendanceService.getHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Belum ada riwayat absensi."),
                      );
                    }

                    final historyList = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final item = historyList[index];
                        final checkIn = item['check_in'];
                        final checkOut = item['check_out'];
                        final alamat =
                            item['check_in_address'] ??
                            'Alamat tidak diketahui';

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 400 + index * 100),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 📅 Tanggal
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatDate(checkIn),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // ✅ CheckIn | ❌ CheckOut sejajar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.login_rounded,
                                            size: 18,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            checkIn != null
                                                ? formatTime(checkIn)
                                                : '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.logout_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            checkOut != null
                                                ? formatTime(checkOut)
                                                : 'Belum Check Out',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color:
                                                  checkOut == null
                                                      ? Colors.orange
                                                      : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // 📍 Alamat di bawah sendiri
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          alamat,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color.fromARGB(205, 0, 0, 0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
