// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dapurame/firebase_options.dart'; // Pastikan path ini benar
import 'package:dapurame/auth_gate.dart'; // Impor halaman AuthGate Anda

// Fungsi main() adalah titik awal aplikasi Anda
void main() async {
  // Pastikan semua binding Flutter sudah siap sebelum menjalankan kode native
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase. Ini wajib dilakukan sebelum menggunakan layanan Firebase lainnya.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Mengatur style status bar agar transparan dan ikonnya gelap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Menjalankan aplikasi
  runApp(const MyApp());
}

// MyApp adalah widget root dari aplikasi Anda
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggabungkan perubahan dari kedua versi
    return MaterialApp(
      // Menghilangkan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,

      // Mengambil ThemeData untuk konsistensi font dan style
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        // Anda bisa menambahkan pengaturan tema lain di sini
      ),

      // Mengatur AuthGate sebagai halaman pertama yang akan dimuat.
      // Ini adalah pendekatan yang benar untuk menangani sesi login.
      home: const AuthGate(),
    );
  }
}
