// lib/verifikasi_email.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dapurame/bookmark.dart'; // Halaman tujuan setelah verifikasi

class VerifikasiEmailScreen extends StatefulWidget {
  const VerifikasiEmailScreen({super.key});

  @override
  State<VerifikasiEmailScreen> createState() => _VerifikasiEmailScreenState();
}

class _VerifikasiEmailScreenState extends State<VerifikasiEmailScreen> {
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Kirim email verifikasi segera setelah halaman dimuat
    FirebaseAuth.instance.currentUser?.sendEmailVerification();

    // Mulai timer untuk memeriksa status verifikasi setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    // Reload user untuk mendapatkan status terbaru dari server Firebase
    await user?.reload();

    if (user != null && user.emailVerified) {
      _timer?.cancel(); // Hentikan timer
      if (mounted) {
        // Arahkan ke halaman utama setelah verifikasi berhasil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BookmarkPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    // Pastikan timer dihentikan saat halaman ditutup untuk menghindari memory leak
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
                'Link verifikasi telah dikirim ke email:\n${user?.email}\n\nSilakan periksa kotak masuk atau folder spam Anda dan klik link tersebut untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    user?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email verifikasi baru telah dikirim.'),
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
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Batal',
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
