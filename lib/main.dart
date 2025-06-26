// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini digenerate oleh FlutterFire
import 'auth_gate.dart'; // Impor halaman AuthGate Anda

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
    return const MaterialApp(
      // Menghilangkan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,

      // Mengatur AuthGate sebagai halaman pertama yang akan dimuat.
      // AuthGate akan secara otomatis menentukan apakah harus menampilkan
      // halaman login atau halaman utama (HomePage).
      home: AuthGate(),
    );
  }
}
