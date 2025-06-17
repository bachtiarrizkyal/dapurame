import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dapurame/bookmark.dart'; // Halaman tujuan setelah verifikasi
import 'package:dapurame/masuk.dart'; // Import halaman masuk untuk navigasi saat batal

class VerifikasiEmailScreen extends StatefulWidget {
  // 1. Tambahkan variabel untuk menampung email
  final String? email;

  // 2. Tambahkan email ke constructor
  const VerifikasiEmailScreen({super.key, this.email});

  @override
  State<VerifikasiEmailScreen> createState() => _VerifikasiEmailScreenState();
}

class _VerifikasiEmailScreenState extends State<VerifikasiEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Email sudah dikirim dari halaman daftar, jadi baris ini sebenarnya bisa dinonaktifkan
    // untuk menghindari pengiriman ganda, tapi tidak masalah jika tetap ada.
    // FirebaseAuth.instance.currentUser?.sendEmailVerification();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user =
        FirebaseAuth
            .instance
            .currentUser; // Ambil ulang data user setelah reload

    if (user != null && user.emailVerified) {
      _timer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifikasi berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BookmarkPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan email dari widget jika ada, jika tidak, ambil dari user saat ini.
    final emailToShow =
        widget.email ?? FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3ED),
      appBar: AppBar(
        title: const Text(
          "Verifikasi Email",
          style: TextStyle(color: Color(0xFF5A3E2D)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5A3E2D)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Email Verifikasi Telah Dikirim',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A3E2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                // 3. Tampilkan email yang diterima dari halaman sebelumnya
                'Link verifikasi telah dikirim ke email:\n${emailToShow ?? 'email tidak ditemukan'}\n\nSilakan periksa kotak masuk atau folder spam Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email verifikasi baru telah dikirim.'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89F43),
                  ),
                  child: const Text(
                    'Kirim Ulang Email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  _timer?.cancel(); // Hentikan timer sebelum logout
                  await FirebaseAuth.instance.signOut();
                  // Arahkan kembali ke halaman Masuk setelah batal
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MasukScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: const Text(
                  'Batal & Kembali ke Halaman Masuk',
                  style: TextStyle(color: Color(0xFF5A3E2D)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
