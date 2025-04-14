import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas_absen/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // Untuk menampilkan indikator loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8656D6),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back_ios, color: Colors.white),
                      Row(
                        children: [
                          const Text(
                            "already have an account?",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 18),
                          OutlinedButton(
                            onPressed: () {
                              Get.toNamed('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Sign in"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    "Sign Up",
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
                SizedBox(
                  height: 590,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: (MediaQuery.of(context).size.width - 345) / 2,
                        child: Container(
                          width: 350,
                          height: 65,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2A0F0),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),
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
                            const SizedBox(height: 17),
                            Text(
                              "Get started free",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Free forever. No credit card needed.",
                              style: TextStyle(
                                color: Color.fromARGB(255, 98, 98, 98),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 27),
                            // Form fields
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Your name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: emailController,
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
                            // Button Sign Up
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          bool success =
                                              await AuthService.register(
                                                nameController.text,
                                                emailController.text,
                                                passwordController.text,
                                              );
                                          if (success) {
                                            Get.offAllNamed(
                                              '/login',
                                            ); // Redirect ke home
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9848FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Divider dan Sosmed
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text("or sign up with"),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 40,
                                  ),
                                  label: Text(
                                    "Sign in with Google",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 15, // Ukuran teks
                                        fontWeight:
                                            FontWeight.w600, // Tebal font
                                        letterSpacing: 0.5, // Jarak antar huruf
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(
                                      260,
                                      50,
                                    ), // ⬅️ Lebar: 250, Tinggi: 50
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blueAccent,
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(
                                      60,
                                      50,
                                    ), // ⬅️ Ukuran kotak (bisa disesuaikan)
                                    padding:
                                        EdgeInsets
                                            .zero, // Untuk buang padding bawaan
                                  ),
                                  child: const Icon(Icons.facebook, size: 27),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
