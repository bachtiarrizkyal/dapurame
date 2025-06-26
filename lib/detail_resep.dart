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
        builder: (context, recipeSnapshot) { // Rename snapshot to recipeSnapshot
          if (recipeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipeSnapshot.hasError) {
            print("Error fetching recipe details: ${recipeSnapshot.error}");
            return Center(child: Text('Error: ${recipeSnapshot.error}'));
          }

          if (!recipeSnapshot.hasData || !recipeSnapshot.data!.exists) {
            return const Center(child: Text('Resep tidak ditemukan.'));
          }

          // Data resep dari Firebase
          final Map<String, dynamic> recipeData = recipeSnapshot.data!.data() as Map<String, dynamic>;

          // Safely get values from Firebase data
          final String namaResep = recipeData['nama'] ?? 'Judul Resep';
          final String deskripsi = recipeData['deskripsi'] ?? 'Deskripsi belum tersedia untuk resep ini.';
          final String imageUrl = recipeData['image_url'] ?? 'assets/images/default.png';
          
          // Pastikan rating adalah number di Firebase atau gunakan tryParse
          final int ratingInt = (recipeData['rating'] is num) ? recipeData['rating'].toInt() : 0;
          
          final String waktuMasak = recipeData['waktu_masak'] ?? 'N/A';
          
          final String userUid = recipeData['user_id'] ?? '';
          final String createdDate = _formatTimestamp(recipeData['created_at']);
          
          // Nested FutureBuilder to fetch user data
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
            builder: (context, userSnapshot) { // New snapshot for user data
              String userName = 'Anonim';
              String userUsername = '@user';
              String userProfileImagePath = 'assets/images/profilemale.jpeg'; // Default

              if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData && userSnapshot.data!.exists) {
                final Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                userName = userData['nama'] ?? 'Anonim'; // Ambil 'nama' dari koleksi users
                userUsername = userData['username'] != null ? '@${userData['username']}' : '@user'; // Ambil 'username'
                userProfileImagePath = userData['profile_image_url'] ?? 'assets/images/profilemale.jpeg'; // Ambil 'profile_image_url' dari koleksi users
              }

              // Mengambil bahan
              final List<dynamic> bahanList = recipeData['bahan'] ?? [];

              // Mengambil cara membuat
              final dynamic caraMembuatRaw = recipeData['cara_membuat'];
              List<String> caraMembuatSteps;

              if (caraMembuatRaw is String) {
                caraMembuatSteps = caraMembuatRaw.split('\n').where((s) => s.trim().isNotEmpty).toList();
              } else if (caraMembuatRaw is List) {
                caraMembuatSteps = caraMembuatRaw.map((e) => e.toString()).toList();
              } else {
                caraMembuatSteps = ['Langkah-langkah belum tersedia.'];
              }

              final bool isNetworkRecipeImage = imageUrl.startsWith('http');
              final bool isLocalFileRecipeImage = imageUrl.startsWith('/data/user/') || imageUrl.startsWith('/storage/emulated/') || imageUrl.startsWith('file:///');

              return Stack(
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
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading network recipe image: $imageUrl, Error: $error");
                                    return Image.asset(
                                      'assets/images/default.png',
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : isLocalFileRecipeImage
                                  ? Image.file(
                                      File(imageUrl),
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print("Error loading local file recipe image: $imageUrl, Error: $error");
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
                                        print("Error loading asset recipe image: $imageUrl, Error: $error");
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
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: userProfileImagePath.startsWith('http')
                                        ? NetworkImage(userProfileImagePath) as ImageProvider
                                        : AssetImage(userProfileImagePath),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$userName • $createdDate',
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

                              _sectionTitle("Bahan - Bahan"),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: bahanList.asMap().entries.map<Widget>((entry) { 
                                  int idx = entry.key; 
                                  dynamic item = entry.value; 

                                  if (item is Map<String, dynamic>) {
                                    final String namaBahan = item['nama'] ?? 'Bahan tidak diketahui';
                                    final String jumlahBahan = item['jumlah'] ?? 'Jumlah tidak diketahui';
                                    return _numberedStepText(idx + 1, '$namaBahan: $jumlahBahan');
                                  }
                                  return const SizedBox.shrink();
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

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
          );
        },
      ),
    );
  }

  // Helper untuk format timestamp
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

  Widget _numberedBulletText(int stepNumber, String text) {
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