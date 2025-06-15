import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Utama Anda')),
      body: const Center(
        child: Text(
          'Selamat datang di aplikasi!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
