import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'tambah_resep.dart';
import 'nutrisi.dart';
import 'bookmark.dart';

class ResepkuPage extends StatelessWidget {
  const ResepkuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
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
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF662B0E)),
                  hintText: 'Cari Resep',
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
          
          // Resep List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resep')
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
                    child: CircularProgressIndicator(
                      color: Color(0xFFE68B2B),
                    ),
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
                          'Belum ada resep',
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
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                    return ResepCard(
                      documentId: document.id,
                      nama: data['nama'] ?? 'No Name',
                      deskripsi: data['deskripsi'] ?? 'No Description',
                      imagePath: data['image_url'] ?? 'default_placeholder',
                      waktuMasak: data['waktu_masak'] ?? '30 menit',
                      rating: (data['rating'] ?? 4).toInt(),
                      data: data,
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
            MaterialPageRoute(
              builder: (context) => const TambahResepPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF662B0E),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 2, 
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
              // Home - belum ada halaman, skip
              break;
            case 1:
              // Nutrisi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
              // Resepku - already here
              break;
            case 3:
              // Bookmark
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkPage()),
              );
              break;
            case 4:
              // Profil - belum ada halaman, skip
              break;
          }
        },
      ),
    );
  }
}

class ResepCard extends StatelessWidget {
  final String documentId;
  final String nama;
  final String deskripsi;
  final String imagePath;
  final String waktuMasak;
  final int rating;
  final Map<String, dynamic> data;

  const ResepCard({
    super.key,
    required this.documentId,
    required this.nama,
    required this.deskripsi,
    required this.imagePath,
    required this.waktuMasak,
    required this.rating,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  width: 75,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 75,
                      height: 68,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                )
              : (imagePath.startsWith('/') && File(imagePath).existsSync())
                  ? Image.file(
                      File(imagePath),
                      width: 75,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 75,
                          height: 68,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : (imagePath != 'default_placeholder' && imagePath.startsWith('assets/'))
                      ? Image.asset(
                          imagePath,
                          width: 75,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 75,
                              height: 68,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 75,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE68B2B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE68B2B),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Color(0xFFE68B2B),
                            size: 30,
                          ),
                        ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A2104),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deskripsi,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                color: Color(0xFF4A2104),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  size: 14,
                  color: Color(0xFFE68B2B),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    waktuMasak,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFE68B2B),
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahResepPage(
                        documentId: documentId,
                        initialData: data,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFFE68B2B),
                    size: 16,
                  ),
                ),
              ),
              // Delete Button
              GestureDetector(
                onTap: () {
                  _showDeleteDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                ),
                const Icon(
                  Icons.delete,
                  size: 120,
                  color: Color(0xFFE68B2B),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kamu yakin akan menghapus\nresep "$nama"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2104),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFE68B2B),
                          size: 28,
                        ),
                      ),
                    ),
                    // Vertical Line
                    Container(
                      height: 28,
                      width: 0.5,
                      color: const Color(0xFFE68B2B),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Confirm Delete Button
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('resep')
                              .doc(documentId)
                              .delete();
                          
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Resep "$nama" berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus resep: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFFE68B2B),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}