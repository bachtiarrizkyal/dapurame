// detail_resep.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dapurame/home_page.dart';

class DetailResepPage extends StatelessWidget {
  // This map will hold the data of the selected recipe
  final Map<String, String> recipe;

  const DetailResepPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set the status bar style for this page
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF8B4513),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                recipe['imagePath']!,
                fit: BoxFit.cover,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // Handle favorite button press
                    },
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF662B0E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe['rating']!} Rating',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF662B0E),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe['time']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF662B0E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe['description']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF662B0E),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bahan-bahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF662B0E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for ingredients list
                  _buildIngredientItem('Daging Sapi', '500 gram'),
                  _buildIngredientItem('Kluwek', '5 butir'),
                  _buildIngredientItem('Bawang Merah', '8 siung'),
                  _buildIngredientItem('Bawang Putih', '5 siung'),
                  _buildIngredientItem('Air', '1 liter'),
                  const SizedBox(height: 24),
                  const Text(
                    'Langkah-langkah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF662B0E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for steps list
                  _buildStepItem(1, 'Haluskan semua bumbu halus. Tumis hingga harum.'),
                  _buildStepItem(2, 'Masukkan daging, aduk hingga berubah warna.'),
                  _buildStepItem(3, 'Tuang air, masak hingga daging empuk.'),
                  _buildStepItem(4, 'Sajikan dengan nasi hangat dan tauge.'),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Resep dari',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B4513),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: AssetImage(recipe['profileImagePath']!),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe['author']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String ingredient, String quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF8B4513)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$ingredient: $quantity',
              style: const TextStyle(fontSize: 16, color: Color(0xFF662B0E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String stepDescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber.',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF662B0E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stepDescription,
              style: const TextStyle(fontSize: 16, color: Color(0xFF662B0E), height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

// detail_resep.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:dapurame/home_page.dart';

class DetailResepPage extends StatefulWidget {
  final String documentId;

  const DetailResepPage({super.key, required this.documentId});

  @override
  State<DetailResepPage> createState() => _DetailResepPageState();
}

class _DetailResepPageState extends State<DetailResepPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('resep').doc(widget.documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching recipe details: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Resep tidak ditemukan.'));
          }

          // Data resep dari Firebase
          final Map<String, dynamic> recipeData = snapshot.data!.data() as Map<String, dynamic>;
          final String nama = recipeData['nama'] ?? 'Judul Resep';
          final String deskripsi = recipeData['deskripsi'] ?? 'Deskripsi belum tersedia untuk resep ini.';
          final String imageUrl = recipeData['image_url'] ?? 'assets/images/default.png';
          
          // Pastikan rating adalah number di Firebase atau gunakan tryParse
          final int ratingInt = (recipeData['rating'] is num) ? recipeData['rating'].toInt() : 0;
          
          final String waktuMasak = recipeData['waktu_masak'] ?? 'N/A';
          final String author = recipeData['author'] ?? 'Anonim';
          final String profileImagePath = recipeData['profile_image_path'] ?? 'assets/images/profilemale.jpeg';
          final String createdDate = _formatTimestamp(recipeData['created_at']);
          final String userIdDisplay = (recipeData['user_id'] != null && recipeData['user_id'].toString().isNotEmpty)
              ? '@${recipeData['user_id']}'
              : '@user';
          final List<dynamic> bahanList = recipeData['bahan'] ?? [];

          final dynamic caraMembuatRaw = recipeData['cara_membuat'];
          List<String> caraMembuatSteps;

          if (caraMembuatRaw is String) {
            caraMembuatSteps = caraMembuatRaw.split('\n').where((s) => s.trim().isNotEmpty).toList();
          } else if (caraMembuatRaw is List) {
            caraMembuatSteps = caraMembuatRaw.map((e) => e.toString()).toList();
          } else {
            caraMembuatSteps = ['Langkah-langkah belum tersedia.'];
          }

          // Determine image source
          final bool isNetworkImage = imageUrl.startsWith('http');
          final bool isLocalFileImage = imageUrl.startsWith('/data/user/') || imageUrl.startsWith('/storage/emulated/') || imageUrl.startsWith('file:///');

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Gambar Header
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: isNetworkImage
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading network image for detail: $imageUrl, Error: $error");
                                return Image.asset(
                                  'assets/images/default.png',
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : isLocalFileImage
                              ? Image.file(
                                  File(imageUrl),
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading local file image for detail: $imageUrl, Error: $error");
                                    return Image.asset(
                                      'assets/images/default.png',
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading asset image for detail: $imageUrl, Error: $error");
                                    return Image.asset(
                                      'assets/images/default.png',
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bagian Profil dan Tanggal Upload
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                  profileImagePath,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$author • $createdDate', // Data author dan tanggal
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2104),
                                    ),
                                  ),
                                  Text(
                                    userIdDisplay, // Data user_id
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
                          
                          // Judul Resep dan Waktu Memasak
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  nama, // Data nama resep
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
                                      waktuMasak, // Data waktu memasak
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
                          
                          // Rating Bintang
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < ratingInt
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFE68B2B),
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Disukai oleh +99 orang', // Ini masih hardcoded
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w200,
                              color: Color(0xFF4A2104),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Deskripsi Resep
                          Text(
                            deskripsi, // Data deskripsi resep
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4A2104),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Bahan-bahan (dinamis dari Firebase)
                          _sectionTitle("Bahan - Bahan"),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bahanList.map<Widget>((item) {
                              if (item is Map<String, dynamic>) {
                                final String namaBahan = item['nama'] ?? 'Bahan tidak diketahui';
                                final String jumlahBahan = item['jumlah'] ?? 'Jumlah tidak diketahui';
                                return _bulletText('$namaBahan: $jumlahBahan');
                              }
                              return const SizedBox.shrink(); // Hide if not a map
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Cara Membuat (dinamis dari Firebase)
                          _sectionTitle("Cara Membuat"),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: caraMembuatSteps.asMap().entries.map<Widget>((entry) {
                              int idx = entry.key;
                              String step = entry.value;
                              return _numberedStepText(idx + 1, step);
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 30,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
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

              Positioned(
                top: 30,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resep ditambahkan ke favorit!')),
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
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini';
    }
    else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Kemarin';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Color(0xFF662B0E),
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(
              Icons.circle,
              size: 8,
              color: Color(0xFF8B4513),
            ), // Warna bullet
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A2104),
                height: 1.4, // Line height
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // Helper baru untuk Cara Membuat (numbered list)
  Widget _numberedStepText(int stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber.',
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
}