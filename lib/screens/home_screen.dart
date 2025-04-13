import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8656D6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Welcome!', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Home Page',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat datang di aplikasi absensi. Silakan eksplorasi menu di bawah atau mulai aktivitasmu.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // aksi logout atau navigasi lainnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8656D6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Mulai Absensi"),
            ),
          ],
        ),
      ),
    );
  }
}
