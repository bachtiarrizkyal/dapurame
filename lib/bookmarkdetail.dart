// lib/bookmarkdetail.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class BookmarkDetailPage extends StatefulWidget {
  final String bookmarkDocumentId; // ID dokumen di koleksi 'bookmark'

  const BookmarkDetailPage({Key? key, required this.bookmarkDocumentId})
    : super(key: key);

  @override
  State<BookmarkDetailPage> createState() => _BookmarkDetailPageState();
}

class _BookmarkDetailPageState extends State<BookmarkDetailPage> {
  final TextEditingController _catatanController = TextEditingController();

  // State hanya untuk melacak mode edit Catatan
  bool _isEditingCatatan = false;

  Map<String, dynamic>? _bookmarkData; // Data dari Firestore
  User? _currentUser;
  bool _isLoading = true; // State untuk loading awal

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchBookmarkData();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookmarkData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('bookmark')
              .doc(widget.bookmarkDocumentId)
              .get();

      if (doc.exists && mounted) {
        setState(() {
          _bookmarkData = doc.data() as Map<String, dynamic>;
          _catatanController.text = _bookmarkData!['catatan'] ?? '';
          _isLoading = false;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark tidak ditemukan.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail bookmark: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  // Fungsi ini sekarang hanya akan digunakan untuk memperbarui catatan
  Future<void> _updateCatatan() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk mengedit catatan.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('bookmark')
          .doc(widget.bookmarkDocumentId)
          .update({
            'catatan': _catatanController.text.trim(),
            'updated_at': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchBookmarkData(); // Refresh data setelah update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui catatan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Widget untuk judul section yang tidak bisa diedit
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Color(0xFF662B0E),
      ),
    );
  }

  // Widget untuk judul section yang BISA diedit
  Widget _buildEditableSectionTitle(
    String title,
    bool isEditing,
    VoidCallback onEditTap,
    VoidCallback onSaveTap,
    VoidCallback onCancelTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF662B0E),
          ),
        ),
        if (isEditing)
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                onPressed: onSaveTap,
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                onPressed: onCancelTap,
              ),
            ],
          )
        else
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFFE68B2B),
              size: 20,
            ),
            onPressed: onEditTap,
          ),
      ],
    );
  }

  Widget _numberedListItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2104),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A2104),
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFAF2),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF662B0E)),
        ),
      );
    }

    final String namaResep = _bookmarkData!['nama'] ?? 'Judul Resep';
    final String deskripsi =
        _bookmarkData!['deskripsi'] ?? 'Deskripsi belum tersedia.';
    final String imageUrl =
        _bookmarkData!['image_url'] ?? 'assets/images/default.png';
    final int ratingInt =
        (_bookmarkData!['rating'] is num)
            ? _bookmarkData!['rating'].toInt()
            : 0;
    final String waktuMasak = _bookmarkData!['waktu_masak'] ?? 'N/A';
    final String userUidPengupload = _bookmarkData!['user_id'] ?? '';
    final List<dynamic> bahanDataList = _bookmarkData!['bahan'] ?? [];
    final dynamic caraMembuatRaw = _bookmarkData!['cara_membuat'];

    List<String> caraMembuatDataList;
    if (caraMembuatRaw is String) {
      caraMembuatDataList =
          caraMembuatRaw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } else if (caraMembuatRaw is List) {
      caraMembuatDataList = caraMembuatRaw.map((e) => e.toString()).toList();
    } else {
      caraMembuatDataList = ['Langkah-langkah belum tersedia.'];
    }

    final bool isNetworkRecipeImage = imageUrl.startsWith('http');
    final bool isLocalFileRecipeImage =
        imageUrl.startsWith('/data/user/') ||
        imageUrl.startsWith('/storage/emulated/');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child:
                      isNetworkRecipeImage
                          ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, e, s) => Image.asset(
                                  'assets/images/default.png',
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : isLocalFileRecipeImage
                          ? Image.file(
                            File(imageUrl),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, e, s) => Image.asset(
                                  'assets/images/default.png',
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, e, s) => Image.asset(
                                  'assets/images/default.png',
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PERBAIKAN: Gunakan FutureBuilder untuk mengambil data penulis resep ---
                      FutureBuilder<DocumentSnapshot>(
                        future:
                            userUidPengupload.isNotEmpty
                                ? FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userUidPengupload)
                                    .get()
                                : null,
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          String authorName = 'Anonim';
                          String authorUsername = '@anonim';
                          String? authorProfileImageUrl;

                          if (userSnapshot.hasData &&
                              userSnapshot.data!.exists) {
                            final userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            authorName = userData['nama'] ?? 'Anonim';
                            authorUsername =
                                '@${userData['username'] ?? 'anonim'}';
                            authorProfileImageUrl =
                                userData['profile_image_url'];
                          }

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    (authorProfileImageUrl != null)
                                        ? NetworkImage(authorProfileImageUrl)
                                        : const AssetImage(
                                              'assets/images/profilemale.jpeg',
                                            )
                                            as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2104),
                                    ),
                                  ),
                                  Text(
                                    authorUsername,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              namaResep,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A2104),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEACC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 18,
                                  color: Color(0xFFE68B2B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  waktuMasak,
                                  style: const TextStyle(
                                    color: Color(0xFF4A2104),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < ratingInt ? Icons.star : Icons.star_border,
                            color: const Color(0xFFE68B2B),
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        deskripsi,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A2104),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Bagian Resep dan Catatan ---
                      _buildSectionTitle("Bahan - Bahan"),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            bahanDataList.asMap().entries.map<Widget>((entry) {
                              dynamic item = entry.value;
                              if (item is Map<String, dynamic>) {
                                return _numberedListItem(
                                  entry.key,
                                  '${item['nama'] ?? ''}: ${item['jumlah'] ?? ''}',
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle("Cara Membuat"),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            caraMembuatDataList
                                .asMap()
                                .entries
                                .map<Widget>(
                                  (entry) =>
                                      _numberedListItem(entry.key, entry.value),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 24),

                      const Divider(),
                      const SizedBox(height: 16),

                      _buildEditableSectionTitle(
                        "Catatan Pribadi",
                        _isEditingCatatan,
                        () => setState(() => _isEditingCatatan = true),
                        () {
                          _updateCatatan();
                          setState(() => _isEditingCatatan = false);
                        },
                        () {
                          setState(() {
                            _catatanController.text =
                                _bookmarkData!['catatan'] ?? '';
                            _isEditingCatatan = false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_isEditingCatatan)
                        TextFormField(
                          controller: _catatanController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan pribadimu...',
                            isDense: true,
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _catatanController.text.isEmpty
                                ? 'Ketuk ikon edit untuk menambahkan catatan.'
                                : _catatanController.text,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  _catatanController.text.isEmpty
                                      ? Colors.grey[600]
                                      : const Color(0xFF4A2104),
                              height: 1.5,
                              fontStyle:
                                  _catatanController.text.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
