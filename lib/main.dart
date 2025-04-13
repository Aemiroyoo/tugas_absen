import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tugas_absen/screens/home_screen.dart';
import 'package:tugas_absen/screens/register_screen.dart';
import 'screens/login_screen.dart';
// import 'screens/sign_up_screen.dart';

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
      initialRoute: '/signup',
      getPages: [
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/login', page: () => const SignInScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}
