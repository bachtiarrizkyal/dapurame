import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dapurame/splash_screen.dart'; // Menggunakan SplashScreen sebagai halaman awal

// Fungsi main diubah menjadi async untuk inisialisasi Firebase
void main() async {
  // Pastikan semua widget binding sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan konfigurasi platform Anda saat ini
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Jalankan aplikasi setelah Firebase siap
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      // Halaman awal aplikasi diatur ke SplashScreen.
      // Nantinya, SplashScreen yang akan menentukan apakah akan menampilkan
      // halaman login atau halaman utama (HomePage).
      home: const SplashScreen(),
    );
  }
}
