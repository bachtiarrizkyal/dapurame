// Buat file baru, misal: lib/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dapurame/home_page.dart'; // Halaman utama setelah login
import 'package:dapurame/masuk_atau_daftar.dart'; // Halaman jika belum login

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Stream ini secara konstan memantau status login
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Saat sedang memeriksa...
          // Tampilkan loading indicator selagi Firebase memeriksa token di perangkat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5A3E2D)),
            );
          }

          // 2. Jika pemeriksaan selesai dan ADA DATA (user sudah login)
          if (snapshot.hasData) {
            // Arahkan langsung ke halaman utama aplikasi
            return const HomePage();
          }
          // 3. Jika pemeriksaan selesai dan TIDAK ADA DATA (user belum login)
          else {
            // Arahkan ke halaman pilihan masuk atau daftar
            return const MasukAtauDaftarScreen();
          }
        },
      ),
    );
  }
}
