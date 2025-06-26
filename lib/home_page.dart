// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Diperlukan untuk Image.file

// Impor semua halaman untuk navigasi
import 'package:dapurame/navbar.dart';
import 'package:dapurame/nutrisi.dart';
import 'package:dapurame/resepku.dart';
import 'package:dapurame/bookmark.dart';
import 'package:dapurame/profile.dart';
import 'package:dapurame/notification_page.dart';
import 'package:dapurame/detail_resep.dart';

// Catatan: Fungsi main() ini sebaiknya ada di file terpisah (main.dart)
// untuk kerapian proyek.
void main() {
  // Pastikan Firebase sudah diinisialisasi di file main.dart utama Anda.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Mulai dari HomePage sebagai induk navigasi
    ),
  );
}

// --- BAGIAN INDUK NAVIGASI ---
// HomePage sekarang menjadi "Induk" atau "Shell" untuk navigasi.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai urutan navbar
  final List<Widget> _pages = [
    const HomePageContent(), // Konten untuk Home (index 0)
    const NutrisiPage(), // Halaman Nutrisi (index 1)
    const ResepkuPage(), // Halaman Resepku (index 2)
    const BookmarkPage(), // Halaman Bookmark (index 3)
    const ProfilePage(), // Halaman Profil (index 4)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Cukup update state, UI akan otomatis berganti halaman
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// --- BAGIAN KONTEN HALAMAN HOME ---
// Widget ini berisi UI spesifik untuk tab Home.
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  String _greetingName = 'Pengguna'; // Default nama
  User? _currentUser; // Tambahkan ini untuk melacak pengguna saat ini
  Set<String> _bookmarkedRecipeIds = {}; // Set untuk menyimpan ID resep yang dibookmark

  final List<Map<String, String>> bannerItems = [
    {
      'image': 'assets/images/ramen.jpeg',
      'tag': 'Resep Terbaru!',
      'title': 'Ramen Ookamizu',
    },
    {
      'image': 'assets/images/sushi.jpg',
      'tag': 'Paling Favorit!',
      'title': 'Sushi Shinomiya',
    },
    {
      'image': 'assets/images/cake.jpg',
      'tag': 'Hidangan Penutup!',
      'title': 'Cake Berry',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          _fetchUserData();
          _fetchUserBookmarks();
        } else {
          // Clear bookmarks if user logs out
          setState(() {
            _greetingName = 'Pengguna';
            _bookmarkedRecipeIds.clear();
          });
        }
      }
    });
    if (_currentUser != null) {
      _fetchUserData();
      _fetchUserBookmarks();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil nama pengguna dari Firestore
  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();
      if (userDoc.exists && mounted) {
        setState(() {
          _greetingName = userDoc.get('username') ?? 'Pengguna';
        });
      }
    }
  }

  // Fungsi untuk mengambil ID resep yang dibookmark oleh pengguna
  Future<void> _fetchUserBookmarks() async {
    if (_currentUser == null) {
      setState(() {
        _bookmarkedRecipeIds.clear();
      });
      return;
    }
    try {
      QuerySnapshot bookmarkSnapshot = await FirebaseFirestore.instance
          .collection('bookmark')
          .where('bookmarked_by_user_id', isEqualTo: _currentUser!.uid)
          .get();

      if (mounted) {
        setState(() {
          _bookmarkedRecipeIds = bookmarkSnapshot.docs
              .map((doc) => doc.get('original_recipe_id') as String)
              .toSet();
        });
      }
    } catch (e) {
      print("Error fetching user bookmarks: $e");
    }
  }

  // Fungsi untuk mem-bookmark atau unbookmark resep
  Future<void> _toggleBookmark(
    String recipeDocumentId,
    Map<String, dynamic> recipeData,
  ) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk membookmark resep.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final isCurrentlyBookmarked = _bookmarkedRecipeIds.contains(recipeDocumentId);

      if (isCurrentlyBookmarked) {
        // Hapus bookmark
        QuerySnapshot existingBookmarks = await FirebaseFirestore.instance
            .collection('bookmark')
            .where('original_recipe_id', isEqualTo: recipeDocumentId)
            .where('bookmarked_by_user_id', isEqualTo: _currentUser!.uid)
            .get();

        for (DocumentSnapshot doc in existingBookmarks.docs) {
          await doc.reference.delete();
        }
        if (mounted) {
          setState(() {
            _bookmarkedRecipeIds.remove(recipeDocumentId);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil dihapus dari bookmark!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Tambah bookmark
        Map<String, dynamic> bookmarkData = Map.from(recipeData);
        bookmarkData['original_recipe_id'] = recipeDocumentId;
        bookmarkData['bookmarked_by_user_id'] = _currentUser!.uid;
        bookmarkData['bookmarked_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('bookmark')
            .add(bookmarkData);
        if (mounted) {
          setState(() {
            _bookmarkedRecipeIds.add(recipeDocumentId);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil ditambahkan ke bookmark!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan sapaan dan ikon notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, $_greetingName!', // Sapaan dinamis menggunakan username
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF8B4513),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Temukan ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    TextSpan(
                      text: 'Resep',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    TextSpan(
                      text: ' Terbaik Di DapuRame',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Search Bar dan Filter
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Resep',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF8B4513),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Carousel Banner Resep
              SizedBox(
                height: 200.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = bannerItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildBannerCard(
                        image: item['image']!,
                        tag: item['tag']!,
                        title: item['title']!,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18.0),

              // Dot Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bannerItems.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color:
                          _currentPageIndex == index
                              ? const Color(0xFF8B4513)
                              : const Color.fromRGBO(230, 139, 43, 0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26.0),

              // Grid Resep Dinamis dari Firestore
              const Text(
                'Resep Untuk Kamu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('resep')
                        .where('is_shared', isEqualTo: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return const Center(
                      child: Text('Tidak ada resep yang diunggah.'),
                    );

                  final recipes = snapshot.data!.docs;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeDoc = recipes[index];
                      final recipeData =
                          recipeDoc.data() as Map<String, dynamic>;
                      final String documentId = recipeDoc.id;
                      final String userUid = recipeData['user_id'] ?? '';

                      // Cek apakah resep ini sudah dibookmark oleh pengguna saat ini
                      final bool isBookmarked = _bookmarkedRecipeIds.contains(documentId);

                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userUid)
                                .get(),
                        builder: (context, userSnapshot) {
                          String authorName = 'Anonim';
                          String profilePicturePath =
                              'assets/images/profilemale.jpeg';

                          if (userSnapshot.connectionState ==
                                  ConnectionState.done &&
                              userSnapshot.hasData &&
                              userSnapshot.data!.exists) {
                            final Map<String, dynamic> userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            authorName = userData['nama'] ?? 'Anonim';
                            profilePicturePath =
                                userData['profile_image_url'] ??
                                'assets/images/profilemale.jpeg';
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailResepPage(
                                          documentId: documentId,
                                        ),
                                ),
                              );
                            },
                            child: _buildRecipeCard(
                              imagePath:
                                  recipeData['image_url'] ??
                                  'assets/images/default.png',
                              rating: (recipeData['rating'] ?? 0).toString(),
                              title: recipeData['nama'] ?? 'Tanpa Judul',
                              description: recipeData['deskripsi'] ?? '',
                              author: authorName,
                              time: recipeData['waktu_masak'] ?? 'N/A',
                              profileImagePath: profilePicturePath,
                              isBookmarked: isBookmarked, // Pass the bookmark status
                              onBookmarkTap:
                                  () => _toggleBookmark(documentId, recipeData), // Use toggle function
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk banner (tidak berubah)
  Widget _buildBannerCard({
    required String image,
    required String tag,
    required String title,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 10.0,
              left: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF2DF),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: Offset(2.0, 2.0),
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

  // Helper widget untuk kartu resep (dari versi server, lebih canggih)
  Widget _buildRecipeCard({
    required String imagePath,
    required String rating,
    required String title,
    required String description,
    required String author,
    required String time,
    required String profileImagePath,
    required bool isBookmarked, // NEW: Parameter untuk status bookmark
    required VoidCallback onBookmarkTap,
  }) {
    final bool isNetworkImage = imagePath.startsWith('http');
    final bool isLocalFileImage =
        imagePath.startsWith('/data/user/') ||
        imagePath.startsWith('/storage/emulated/') ||
        imagePath.startsWith('file:///');

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child:
                    isNetworkImage
                        ? Image.network(
                            imagePath,
                            height: 90.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, e, s) => Image.asset(
                                  'assets/images/default.png',
                                  height: 90.0,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                          )
                        : isLocalFileImage
                            ? Image.file(
                                File(imagePath),
                                height: 90.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) => Image.asset(
                                      'assets/images/default.png',
                                      height: 90.0,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(
                                imagePath,
                                height: 90.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) => Image.asset(
                                      'assets/images/default.png',
                                      height: 90.0,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                              ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFF662B0E),
                          size: 14.0,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF662B0E),
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onBookmarkTap,
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border, // CHANGE: Icon based on isBookmarked
                        color: const Color(0xFF662B0E),
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                    color: Color(0xFF662B0E),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFF662B0E),
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14.0),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9.0,
                      backgroundImage:
                          profileImagePath.startsWith('http')
                              ? NetworkImage(profileImagePath) as ImageProvider
                              : AssetImage(profileImagePath),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Color(0xFF662B0E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(250, 228, 194, 1),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF662B0E),
                          fontSize: 8.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}