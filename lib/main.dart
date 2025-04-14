import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas_absen/screens/home_screen.dart';
import 'package:tugas_absen/screens/history_screen.dart';
import 'package:tugas_absen/screens/profile_screen.dart';
import 'package:tugas_absen/screens/login_screen.dart';
import 'package:tugas_absen/screens/register_screen.dart';
import 'package:tugas_absen/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Absensi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/signup',
      getPages: [
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/login', page: () => const SignInScreen()),
        GetPage(name: '/home', page: () => const MainScreen()),
      ],
    );
  }
}
