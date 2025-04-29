import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas_absen/screens/register_screen.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _handleLogin() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Peringatan',
        'Email dan password tidak boleh kosong!',
        backgroundColor: const Color.fromARGB(92, 255, 0, 0),
        colorText: const Color.fromARGB(255, 255, 255, 255),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final result = await AuthService.login(email, password);

      setState(() => isLoading = false);

      if (result['success'] == true) {
        Get.offAll(() => const MainScreen()); // Navigasi ke halaman utama
      } else {
        Get.snackbar(
          'Login Gagal',
          result['message'] ?? 'Terjadi kesalahan',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat login: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF8656D6), // Warna latar belakang ungu
      body: Stack(
        children: [
          // Blur Circle di pojok kanan atas
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromARGB(120, 255, 255, 255),
                    Color.fromARGB(30, 255, 255, 255),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.6, 1.0],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // Konten halaman Sign In
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // const Icon(
                      //   Icons.arrow_back_ios,
                      //   color: Colors.white,
                      //   size: 17,
                      // ),
                      Row(
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(width: 18),
                          OutlinedButton(
                            onPressed: () {
                              Get.toNamed('/signup');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Sign Up"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const Spacer(),
                const SizedBox(height: 100),
                Center(
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 590,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: (MediaQuery.of(context).size.width - 345) / 2,
                            child: Container(
                              width: 350,
                              height: 75,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC2A0F0),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          // Bagian Putih
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  "Welcome back!",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Sign in to continue.",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 98, 98, 98),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Form
                                TextField(
                                  controller: emailController,
                                  // obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Email Address",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Button Sign In
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9848FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        isLoading
                                            ? const CircularProgressIndicator()
                                            : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Divider dan Sosmed
                                // Row(
                                //   children: const [
                                //     Expanded(child: Divider()),
                                //     Padding(
                                //       padding: EdgeInsets.symmetric(
                                //         horizontal: 8.0,
                                //       ),
                                //       child: Text("or sign in with"),
                                //     ),
                                //     Expanded(child: Divider()),
                                //   ],
                                // ),
                                // const SizedBox(height: 16),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     ElevatedButton.icon(
                                //       onPressed: () {},
                                //       icon: const Icon(
                                //         Icons.g_mobiledata,
                                //         size: 40,
                                //       ),
                                //       label: const Text(
                                //         "Sign in with Google",
                                //         style: TextStyle(
                                //           fontSize: 15, // Ukuran teks
                                //           fontWeight:
                                //               FontWeight.w600, // Tebal font
                                //           letterSpacing:
                                //               0.5, // Jarak antar huruf
                                //           color: Colors.black87,
                                //         ),
                                //       ),
                                //       style: ElevatedButton.styleFrom(
                                //         backgroundColor: Colors.white,
                                //         foregroundColor: Colors.black87,
                                //         side: const BorderSide(
                                //           color: Colors.grey,
                                //         ),
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(
                                //             10,
                                //           ),
                                //         ),
                                //         minimumSize: const Size(340, 50),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
