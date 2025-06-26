// lib/bookmarkdetail.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class BookmarkDetailPage extends StatefulWidget {
  final String bookmarkDocumentId; // ID dokumen di koleksi 'bookmark'

  const BookmarkDetailPage({Key? key, required this.bookmarkDocumentId}) : super(key: key);

  @override
  State<BookmarkDetailPage> createState() => _BookmarkDetailPageState();
}

class _BookmarkDetailPageState extends State<BookmarkDetailPage> {
  final TextEditingController _catatanController = TextEditingController();
  List<Map<String, dynamic>> _tempBahan = [];
  final TextEditingController _tempCaraMembuatController = TextEditingController();

  // State untuk melacak mode edit per bagian
  bool _isEditingBahan = false;
  bool _isEditingCaraMembuat = false;
  bool _isEditingCatatan = false;
  
  Map<String, dynamic>? _bookmarkData; // Data dari Firestore
  User? _currentUser;

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
    _tempCaraMembuatController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookmarkData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bookmark')
          .doc(widget.bookmarkDocumentId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _bookmarkData = doc.data() as Map<String, dynamic>;
          
          _catatanController.text = _bookmarkData!['catatan'] ?? '';

          // Pastikan ini adalah List<Map<String, dynamic>>
          _tempBahan = List<Map<String, dynamic>>.from(_bookmarkData!['bahan'] ?? []);

          final dynamic caraMembuatRaw = _bookmarkData!['cara_membuat'];
          if (caraMembuatRaw is String) {
            _tempCaraMembuatController.text = caraMembuatRaw;
          } else if (caraMembuatRaw is List) {
            _tempCaraMembuatController.text = caraMembuatRaw.join('\n');
          } else {
            _tempCaraMembuatController.text = '';
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark tidak ditemukan.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error fetching bookmark detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail bookmark: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _updateBookmarkField(String fieldName, dynamic value) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk mengedit bookmark.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('bookmark')
          .doc(widget.bookmarkDocumentId)
          .update({
        fieldName: value,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_capitalize(fieldName)} berhasil diperbarui!')),
        );
        _fetchBookmarkData(); // Refresh data setelah update
      }
    } catch (e) {
      print("Error updating $fieldName: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui ${_capitalize(fieldName)}: $e')),
        );
      }
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Kemarin';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSectionTitleWithEdit(
      String title, bool isEditing, VoidCallback onEditTap, VoidCallback onSaveTap, VoidCallback onCancelTap) {
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
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: onSaveTap,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: onCancelTap,
              ),
            ],
          )
        else
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFE68B2B), size: 20),
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
    if (_bookmarkData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String namaResep = _bookmarkData!['nama'] ?? 'Judul Resep';
    final String deskripsi = _bookmarkData!['deskripsi'] ?? 'Deskripsi belum tersedia untuk resep ini.';
    final String imageUrl = _bookmarkData!['image_url'] ?? 'assets/images/default.png';
    final int ratingInt = (_bookmarkData!['rating'] is num) ? _bookmarkData!['rating'].toInt() : 0;
    final String waktuMasak = _bookmarkData!['waktu_masak'] ?? 'N/A';
    
    final String userUidPengupload = _bookmarkData!['user_id'] ?? '';
    final String createdDate = _formatTimestamp(_bookmarkData!['created_at']);
    final String authorName = _bookmarkData!['author'] ?? 'Anonim';
    final String userUsername = (_bookmarkData!['username'] != null && _bookmarkData!['username'].toString().isNotEmpty)
        ? '@${_bookmarkData!['username']}'
        : '@user';

    List<dynamic> bahanDataList = _bookmarkData!['bahan'] ?? [];
    List<String> caraMembuatDataList;
    final dynamic caraMembuatRaw = _bookmarkData!['cara_membuat'];
    if (caraMembuatRaw is String) {
      caraMembuatDataList = caraMembuatRaw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } else if (caraMembuatRaw is List) {
      caraMembuatDataList = caraMembuatRaw.map((e) => e.toString()).toList();
    } else {
      caraMembuatDataList = ['Langkah-langkah belum tersedia.'];
    }

    final bool isNetworkRecipeImage = imageUrl.startsWith('http');
    final bool isLocalFileRecipeImage = imageUrl.startsWith('/data/user/') || imageUrl.startsWith('/storage/emulated/') || imageUrl.startsWith('file:///');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: isNetworkRecipeImage
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/default.png', width: double.infinity, height: 220, fit: BoxFit.cover),
                        )
                      : isLocalFileRecipeImage
                          ? Image.file(
                              File(imageUrl),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/default.png', width: double.infinity, height: 220, fit: BoxFit.cover),
                            )
                          : Image.asset(
                              imageUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/default.png', width: double.infinity, height: 220, fit: BoxFit.cover),
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/profilewanda.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$authorName • $createdDate',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2104),
                                ),
                              ),
                              Text(
                                userUsername,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4A2104),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                  style: const TextStyle(color: Color(0xFF4A2104)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < ratingInt ? Icons.star : Icons.star_border,
                            color: const Color(0xFFE68B2B),
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Disukai oleh +99 orang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w200,
                          color: Color(0xFF4A2104),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        deskripsi,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A2104),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bahan-bahan (dengan edit fungsionalitas)
                      _buildSectionTitleWithEdit(
                        "Bahan - Bahan",
                        _isEditingBahan,
                        () => setState(() => _isEditingBahan = true),
                        () { // onSaveTap
                          _updateBookmarkField('bahan', _tempBahan);
                          setState(() => _isEditingBahan = false);
                        },
                        () { // onCancelTap
                          setState(() {
                            _tempBahan = List<Map<String, dynamic>>.from(_bookmarkData!['bahan'] ?? []);
                            _isEditingBahan = false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_isEditingBahan)
                        Column(
                          children: _tempBahan.asMap().entries.map((entry) {
                            int idx = entry.key;
                            Map<String, dynamic> bahan = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: '${bahan['nama']}: ${bahan['jumlah']}',
                                      decoration: InputDecoration(
                                        hintText: 'Nama Bahan: Jumlah',
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (text) {
                                        List<String> parts = text.split(':');
                                        String nama = parts[0].trim();
                                        String jumlah = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
                                        setState(() {
                                          _tempBahan[idx] = {'nama': nama, 'jumlah': jumlah};
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _tempBahan.removeAt(idx);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bahanDataList.asMap().entries.map<Widget>((entry) {
                            int idx = entry.key;
                            dynamic item = entry.value;
                            if (item is Map<String, dynamic>) {
                              final String namaBahan = item['nama'] ?? 'Bahan tidak diketahui';
                              final String jumlahBahan = item['jumlah'] ?? 'Jumlah tidak diketahui';
                              return _numberedListItem(idx, '$namaBahan: $jumlahBahan');
                            }
                            return const SizedBox.shrink();
                          }).toList(),
                        ),
                      if (_isEditingBahan)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _tempBahan.add({'nama': '', 'jumlah': ''});
                              });
                            },
                            icon: const Icon(Icons.add, color: Color(0xFFE68B2B)),
                            label: const Text('Tambah Bahan', style: TextStyle(color: Color(0xFFE68B2B))),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Cara Membuat (dengan edit fungsionalitas)
                      _buildSectionTitleWithEdit(
                        "Cara Membuat",
                        _isEditingCaraMembuat,
                        () => setState(() => _isEditingCaraMembuat = true),
                        () { // onSaveTap
                          _updateBookmarkField('cara_membuat', _tempCaraMembuatController.text);
                          setState(() => _isEditingCaraMembuat = false);
                        },
                        () { // onCancelTap
                          setState(() {
                            final dynamic caraMembuatRaw = _bookmarkData!['cara_membuat'];
                            if (caraMembuatRaw is String) {
                              _tempCaraMembuatController.text = caraMembuatRaw;
                            } else if (caraMembuatRaw is List) {
                              _tempCaraMembuatController.text = caraMembuatRaw.join('\n');
                            }
                            _isEditingCaraMembuat = false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_isEditingCaraMembuat)
                        TextFormField(
                          controller: _tempCaraMembuatController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Masukkan langkah-langkah, pisahkan dengan enter.',
                            isDense: true,
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: caraMembuatDataList.asMap().entries.map<Widget>((entry) {
                            int idx = entry.key;
                            String step = entry.value;
                            return _numberedListItem(idx, step);
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Catatan Pribadi (dengan edit fungsionalitas)
                      _buildSectionTitleWithEdit(
                        "Catatan Pribadi",
                        _isEditingCatatan,
                        () => setState(() => _isEditingCatatan = true),
                        () { // onSaveTap
                          _updateBookmarkField('catatan', _catatanController.text.trim());
                          setState(() => _isEditingCatatan = false);
                        },
                        () { // onCancelTap
                          setState(() {
                            _catatanController.text = _bookmarkData!['catatan'] ?? '';
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
                            hintText: 'Tulis catatan pribadimu tentang resep ini...',
                            isDense: true,
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        Text(
                          _catatanController.text.isEmpty
                              ? 'Belum ada catatan pribadi.'
                              : _catatanController.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A2104),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Back
          Positioned(
            top: 30,
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

          // Tombol Favorite/Bookmark (tetap ada)
          Positioned(
            top: 30,
            right: 16,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aksi favorit belum diimplementasi di sini.')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}