// lib/resepku.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dapurame/tambah_resep.dart';
import 'package:dapurame/detail_resep.dart';

class ResepkuPage extends StatefulWidget {
  const ResepkuPage({super.key});

  @override
  State<ResepkuPage> createState() => _ResepkuPageState();
}

class _ResepkuPageState extends State<ResepkuPage> {
  User? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listener untuk auth state, agar UI update saat user login/logout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  // Method untuk menghapus resep
  Future<void> _deleteRecipe(String documentId, String recipeName) async {
    try {
      await _firestore.collection('resep').doc(documentId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep "$recipeName" berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus resep: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper widget untuk AppBar agar tidak duplikasi kode
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF662B0E),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Resepku',
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan jika pengguna belum login
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAF2),
        appBar: _buildAppBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 80,
                  color: Color(0xFFB7B7B7),
                ),
                SizedBox(height: 16),
                Text(
                  'Login untuk Melihat Resep Anda',
                  style: TextStyle(
                    color: Color(0xFF4A2104),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Simpan dan kelola semua resep pribadimu di sini. Silakan masuk untuk melanjutkan.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // --- PERBAIKAN: Hapus Navbar dari sini ---
      );
    }

    // Tampilan jika pengguna sudah login
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF662B0E)),
                  hintText: 'Cari di resep Anda...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB7B7B7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('resep')
                      .where('user_id', isEqualTo: _currentUser!.uid)
                      .orderBy('created_at', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE68B2B)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Color(0xFFB7B7B7),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada resep yang Anda buat',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF4A2104),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tekan tombol + untuk menambah resep baru',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB7B7B7),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ResepCard(
                      documentId: document.id,
                      data: data,
                      onDelete:
                          () => _deleteRecipe(
                            document.id,
                            data['nama'] ?? 'Tanpa Nama',
                          ),
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TambahResepPage(
                                  documentId: document.id,
                                  initialData: data,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahResepPage()),
          );
        },
        backgroundColor: const Color(0xFF662B0E),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      // --- PERBAIKAN: Hapus Navbar dari sini juga ---
    );
  }
}

// --- ResepCard Disederhanakan untuk Kerapian ---
class ResepCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ResepCard({
    super.key,
    required this.documentId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil data dengan aman
    final String nama = data['nama'] ?? 'Tanpa Nama';
    final String deskripsi = data['deskripsi'] ?? 'Tanpa Deskripsi';
    final String imagePath = data['image_url'] ?? 'assets/images/default.png';
    final String waktuMasak = data['waktu_masak'] ?? 'N/A';
    final int rating = (data['rating'] as num?)?.toInt() ?? 0;

    final bool isNetworkImage = imagePath.startsWith('http');
    final bool isLocalFileImage =
        imagePath.startsWith('/data/user/') ||
        imagePath.startsWith('/storage/emulated/');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailResepPage(documentId: documentId),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 75,
            height: 75,
            child:
                isNetworkImage
                    ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => Image.asset(
                            'assets/images/default.png',
                            fit: BoxFit.cover,
                          ),
                    )
                    : isLocalFileImage
                    ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => Image.asset(
                            'assets/images/default.png',
                            fit: BoxFit.cover,
                          ),
                    )
                    : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => Image.asset(
                            'assets/images/default.png',
                            fit: BoxFit.cover,
                          ),
                    ),
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2104),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  waktuMasak,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFE68B2B),
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _showDeleteDialog(context, nama),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String recipeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Hapus Resep'),
          content: Text('Anda yakin akan menghapus resep "$recipeName"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
