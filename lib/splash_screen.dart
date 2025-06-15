import 'package:flutter/material.dart';
import 'dart:async';

// Import halaman MasukAtauDaftarScreen Anda dengan nama file baru
import 'package:dapurame/masuk_atau_daftar.dart'; // <<< Sesuaikan ini dengan nama proyek Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Navigasi ke halaman MasukAtauDaftarScreen
          builder:
              (context) =>
                  const MasukAtauDaftarScreen(), // <<< Navigasi ke MasukAtauDaftarScreen
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
