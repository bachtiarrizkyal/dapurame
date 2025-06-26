// lib/bookmark.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:dapurame/bookmarkdetail.dart'; // <-- PERBAIKAN: Ganti import ke bookmarkdetail.dart

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listener ini bagus untuk menjaga state tetap update jika ada perubahan login/logout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removeBookmark(String bookmarkDocumentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookmark')
          .doc(bookmarkDocumentId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil dihapus dari bookmark!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper widget untuk membuat AppBar agar tidak duplikasi kode
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF662B0E),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Bookmark',
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
                  Icons.bookmark_remove_outlined,
                  size: 80,
                  color: Color(0xFFB7B7B7),
                ),
                SizedBox(height: 16),
                Text(
                  'Login untuk Melihat Bookmark',
                  style: TextStyle(
                    color: Color(0xFF4A2104),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Simpan semua resep favoritmu di satu tempat. Silakan masuk untuk melanjutkan.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Tampilan jika pengguna sudah login
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF662B0E)),
                  hintText: 'Cari resep di bookmark...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB7B7B7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Daftar Bookmark dari Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('bookmark')
                        .where(
                          'bookmarked_by_user_id',
                          isEqualTo: _currentUser!.uid,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF662B0E),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada resep yang dibookmark.'),
                    );
                  }

                  var bookmarkedRecipes = snapshot.data!.docs;

                  // Filter berdasarkan query pencarian
                  if (_searchQuery.isNotEmpty) {
                    bookmarkedRecipes =
                        bookmarkedRecipes.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title =
                              data['nama']?.toString().toLowerCase() ?? '';
                          return title.contains(_searchQuery.toLowerCase());
                        }).toList();
                  }

                  if (bookmarkedRecipes.isEmpty) {
                    return Center(
                      child: Text('Resep "$_searchQuery" tidak ditemukan.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: bookmarkedRecipes.length,
                    itemBuilder: (context, index) {
                      final bookmarkDoc = bookmarkedRecipes[index];
                      final bookmarkData =
                          bookmarkDoc.data() as Map<String, dynamic>;

                      return BookmarkCard(
                        bookmarkData: bookmarkData,
                        bookmarkDocumentId: bookmarkDoc.id,
                        onDelete: () => _removeBookmark(bookmarkDoc.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk menampilkan satu kartu bookmark
class BookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmarkData;
  final String bookmarkDocumentId;
  final VoidCallback onDelete;

  const BookmarkCard({
    super.key,
    required this.bookmarkData,
    required this.bookmarkDocumentId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Mengambil data dengan aman, memberikan nilai default jika tidak ada
    final String title = bookmarkData['nama'] ?? 'Tanpa Judul';
    final String subtitle =
        bookmarkData['deskripsi'] ?? 'Deskripsi tidak tersedia.';
    final int rating = (bookmarkData['rating'] as num?)?.toInt() ?? 0;
    final String imagePath =
        bookmarkData['image_url'] ?? 'assets/images/default.png';
    final String waktuMasak = bookmarkData['waktu_masak'] ?? 'N/A';

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
        // --- PERBAIKAN: Mengarahkan ke BookmarkDetailPage ---
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Mengirim ID dokumen dari koleksi 'bookmark'
              builder:
                  (context) => BookmarkDetailPage(
                    bookmarkDocumentId: bookmarkDocumentId,
                  ),
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
          title,
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
              subtitle,
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
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFE68B2B),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _showDeleteConfirmation(context, title),
        ),
      ),
    );
  }

  // Dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, String recipeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Hapus Bookmark'),
          content: Text(
            'Anda yakin akan menghapus resep "$recipeName" dari bookmark?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
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
