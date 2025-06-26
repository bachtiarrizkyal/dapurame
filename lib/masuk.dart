// lib/masuk.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dapurame/daftar.dart';
import 'package:dapurame/home_page.dart';

class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // --- 1. TAMBAHKAN STATE UNTUK VISIBILITY PASSWORD ---
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (!mounted) return;

      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          // Jika email belum diverifikasi, logout lagi dan tampilkan pesan
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harap verifikasi email Anda terlebih dahulu.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      // Menggabungkan beberapa kode error untuk satu pesan yang lebih user-friendly
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Email atau password yang Anda masukkan salah.';
      } else {
        message = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan SingleChildScrollView untuk menghindari error overflow saat keyboard muncul
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3ED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header dengan Gambar
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/masuk.png',
                  ), // Pastikan path gambar benar
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF5A3E2D),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3E2D),
                      ),
                    ),
                    const Text(
                      'Masuk untuk Melanjutkan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Color(0xFF5A3E2D),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bagian Form
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Color(0xFF5A3E2D)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Masukkan email Anda',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFFE89F43),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email tidak boleh kosong';
                        if (!value.contains('@') || !value.contains('.'))
                          return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- 2. PERBARUI TEXTFORMFIELD UNTUK PASSWORD ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured, // Gunakan state
                      style: const TextStyle(color: Color(0xFF5A3E2D)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Masukkan password Anda',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFFE89F43),
                        ),
                        // Tambahkan ikon mata di sini
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Ganti ikon berdasarkan state
                            _isPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF5A3E2D),
                          ),
                          onPressed: () {
                            // Panggil setState untuk mengubah state dan membangun ulang UI
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Password tidak boleh kosong';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _performLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE89F43),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DaftarScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF5A3E2D),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          'Belum Punya Akun?',
                          style: TextStyle(
                            color: Color(0xFF5A3E2D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
