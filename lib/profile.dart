// lib/profil.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapurame/masuk_atau_daftar.dart'; // Ganti dengan halaman login/auth gate Anda
import 'package:dapurame/edit_profile.dart'; // <-- IMPOR HALAMAN EDIT PROFIL

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Mengambil data dari Firebase Authentication dan Cloud Firestore
  /// Fungsi ini sekarang bisa dipanggil ulang untuk refresh data
  Future<void> _fetchUserData() async {
    // Tampilkan loading indicator setiap kali data di-fetch ulang
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      try {
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .get();

        if (docSnapshot.exists && mounted) {
          setState(() {
            _userData = docSnapshot.data();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data profil: $e')),
          );
        }
      }
    }

    // Hentikan loading setelah selesai
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fungsi untuk logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MasukAtauDaftarScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3ED),
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: Color(0xFF5A3E2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // --- 1. TAMBAHKAN TOMBOL EDIT DI SINI ---
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note,
              color: Color(0xFF5A3E2D),
              size: 30,
            ),
            onPressed: () {
              // Pastikan data pengguna sudah ada sebelum pindah halaman
              if (_userData != null) {
                // 2. NAVIGASI KE HALAMAN EDIT PROFIL
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Kirim data pengguna saat ini ke halaman edit
                    builder:
                        (context) =>
                            EditProfilePage(currentUserData: _userData!),
                  ),
                ).then((_) {
                  // 3. SETELAH KEMBALI DARI HALAMAN EDIT, FETCH ULANG DATA
                  // Ini akan memperbarui tampilan dengan data baru
                  _fetchUserData();
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5A3E2D)),
              )
              : _currentUser == null
              ? const Center(child: Text("Tidak ada pengguna yang login."))
              : _buildProfileView(),
    );
  }

  /// Widget untuk membangun tampilan profil jika data sudah siap
  Widget _buildProfileView() {
    String username = _userData?['username'] ?? 'Memuat...';
    String nama = _userData?['nama'] ?? 'Memuat...';
    String alamat = _userData?['alamat'] ?? 'Memuat...';
    String noHp = _userData?['no_hp'] ?? 'Memuat...';
    String email = _currentUser?.email ?? 'Memuat...';

    // 4. BUNGKUS DENGAN REFRESH INDICATOR
    return RefreshIndicator(
      onRefresh: _fetchUserData, // Tarik untuk memuat ulang data
      color: const Color(0xFF5A3E2D),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFE89F43),
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3E2D),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            const Divider(color: Color(0xFFE89F43)),
            const SizedBox(height: 20),
            _buildInfoTile(
              icon: Icons.badge_outlined,
              title: 'Nama Lengkap',
              value: nama,
            ),
            _buildInfoTile(
              icon: Icons.location_on_outlined,
              title: 'Alamat',
              value: alamat,
            ),
            _buildInfoTile(
              icon: Icons.phone_android_outlined,
              title: 'Nomor HP',
              value: noHp,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Keluar (Logout)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk menampilkan setiap baris info
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE89F43), size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF5A3E2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
