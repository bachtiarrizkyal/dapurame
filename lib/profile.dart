// lib/profil.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dapurame/masuk_atau_daftar.dart';
import 'package:dapurame/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  User? _currentUser;
  bool _isLoading = true;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (mounted && !_isLoading) {
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MasukAtauDaftarScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final XFile? imageFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (imageFile == null || _currentUser == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${_currentUser!.uid}.jpg');

      await ref.putFile(File(imageFile.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'profile_image_url': url});

      // Panggil _fetchUserData untuk refresh UI dengan data baru dari server
      await _fetchUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note,
              color: Color(0xFF5A3E2D),
              size: 30,
            ),
            onPressed: () {
              if (_userData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditProfilePage(currentUserData: _userData!),
                  ),
                ).then((_) {
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

  Widget _buildProfileView() {
    String username = _userData?['username'] ?? 'Memuat...';
    String nama = _userData?['nama'] ?? 'Memuat...';
    String alamat = _userData?['alamat'] ?? 'Memuat...';
    String noHp = _userData?['no_hp'] ?? 'Memuat...';
    String email = _currentUser?.email ?? 'Memuat...';
    String? profileImageUrl = _userData?['profile_image_url'];

    return RefreshIndicator(
      onRefresh: _fetchUserData,
      color: const Color(0xFF5A3E2D),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showImageSourceActionSheet,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFE89F43),
                    // --- PERBAIKAN DI SINI ---
                    // Tambahkan parameter unik ke URL untuk memaksa refresh dari cache
                    backgroundImage:
                        profileImageUrl != null
                            ? NetworkImage(
                              '$profileImageUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                            )
                            : null,
                    child:
                        profileImageUrl == null
                            ? const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  if (_isUploading)
                    const CircularProgressIndicator(color: Colors.white),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5A3E2D),
                          width: 2,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Color(0xFF5A3E2D),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              icon: Icons.alternate_email_outlined,
              title: 'Username',
              value: username,
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
