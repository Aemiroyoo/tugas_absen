import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_absen/screens/profile_screen.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  // Ambil data profil yang ada dari API
  Future<void> loadProfileData() async {
    final data = await AuthService.getProfile();
    if (data != null) {
      setState(() {
        nameController.text = data['name'];
        emailController.text = data['email'];
      });
    }
  }

  // Kirim data profil baru ke API
  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
      isUpdated = false;
    });

    // Validasi input
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      // Tampilkan snackbar jika ada field yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan email wajib diisi!')),
      );
      return; // Hentikan proses jika input kosong
    }

    // Panggil fungsi updateProfile dari AuthService
    final response = await AuthService.updateProfile(
      nameController.text.trim(),
      emailController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (response) {
      setState(() {
        isUpdated = true;
      });

      // Update SharedPreferences jika perlu
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', nameController.text);
      prefs.setString('userEmail', emailController.text);

      // Tampilkan Snackbar jika berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );

      // Kembali ke MainScreen
      Navigator.pop(
        context,
      ); // Menutup EditProfileScreen dan kembali ke MainScreen
    } else {
      // Tampilkan error atau snackbar jika gagal update
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return 'Nama tidak boleh kosong';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return 'Email tidak boleh kosong';
                //   }
                //   if (!GetUtils.isEmail(value.trim())) {
                //     return 'Format email tidak valid';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    isLoading ? null : updateProfile, // Disable saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Warna tombol
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ), // Padding
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Indicator loading
                        : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              if (isUpdated)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Profil berhasil diperbarui!',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
