import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- 1. Import Firebase Core
import 'firebase_options.dart'; // <-- 2. Import file konfigurasi Firebase
import 'package:dapurame/splash_screen.dart'; // Pastikan path ini benar

// 3. Ubah fungsi main menjadi async
void main() async {
  // 4. Pastikan semua widget binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Inisialisasi Firebase dengan konfigurasi platform Anda saat ini
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
      // Halaman awal Anda tetap SplashScreen, ini sudah benar.
      home: const SplashScreen(),
    );
  }
}
