import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Penting: Import Firebase Auth
import 'package:dapurame/nutrisi.dart';
import 'package:dapurame/resepku.dart';
import 'package:dapurame/bookmark.dart';
import 'package:dapurame/detail_resep.dart';
import 'navbar.dart';
import 'notification_page.dart';
import 'dart:io'; // Diperlukan untuk Image.file

void main() {
  // Pastikan Firebase.initializeApp() sudah dipanggil di file main.dart utama Anda
  // sebelum runApp(). Contoh:
  // void main() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp();
  //   runApp(MaterialApp(...));
  // }
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

// Data untuk carousel banner
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method untuk membookmark resep ke koleksi 'bookmark'
  Future<void> _bookmarkRecipe(String recipeDocumentId, Map<String, dynamic> recipeData) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk membookmark resep.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Buat salinan data resep dari dokumen resep asli
    Map<String, dynamic> bookmarkData = Map.from(recipeData);

    // Tambahkan/ubah field sesuai kebutuhan koleksi 'bookmark'
    bookmarkData['original_recipe_id'] = recipeDocumentId; // Simpan ID resep asli
    bookmarkData['bookmarked_by_user_id'] = currentUser.uid; // User yang sedang membookmark
    bookmarkData['catatan'] = ''; // Field baru: catatan, default kosong
    bookmarkData['bookmarked_at'] = FieldValue.serverTimestamp(); // Waktu bookmark

    // Anda bisa menghapus field yang tidak relevan untuk bookmark jika ada
    // Contoh: bookmarkData.remove('is_shared');

    try {
      // Cek apakah resep sudah dibookmark oleh user ini sebelumnya
      QuerySnapshot existingBookmarks = await FirebaseFirestore.instance
          .collection('bookmark')
          .where('original_recipe_id', isEqualTo: recipeDocumentId)
          .where('bookmarked_by_user_id', isEqualTo: currentUser.uid)
          .get();

      if (existingBookmarks.docs.isNotEmpty) {
        // Jika sudah ada, berikan notifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep ini sudah ada di bookmark Anda!'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Jika belum ada, tambahkan ke koleksi 'bookmark'
        await FirebaseFirestore.instance.collection('bookmark').add(bookmarkData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil ditambahkan ke bookmark!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error bookmarking recipe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan resep ke bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF2),
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
                    'Halo, Wanda!', // Anda bisa mengambil nama user dari Firebase Auth atau koleksi 'users' jika login
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
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
              // Tagline aplikasi
              Text.rich(
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
              SizedBox(height: 16.0),
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Resep',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF8B4513),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF8B4513)),
                        ),
                        filled: true,
                        fillColor: Color(0xFFFFFAF2),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: Colors.white),
                      onPressed: () {
                        // Handle filter icon press
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
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
              SizedBox(height: 18.0),
              // Dot Indicator untuk Carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bannerItems.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: _currentPageIndex == index
                          ? Color(0xFF8B4513)
                          : Color.fromRGBO(230, 139, 43, 0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              SizedBox(height: 26.0),
              // Judul bagian resep yang diminati
              Text(
                'Resep Untuk Kamu', // Ganti "Paling Diminati" menjadi "Resep Untuk Kamu"
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 16.0),
              // Grid Resep dari Firebase Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resep')
                    .where('is_shared', isEqualTo: true) // Filter resep yang dishare
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("Error fetching recipes: ${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('Tidak ada resep yang diunggah.'),
                    );
                  }

                  final recipes = snapshot.data!.docs;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Agar GridView bisa digulir bersama SingleChildScrollView
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeDoc = recipes[index]; // DocumentSnapshot
                      final recipeData = recipeDoc.data() as Map<String, dynamic>; // Data resep
                      final String documentId = recipeDoc.id; // ID dokumen resep
                      final String userUid = recipeData['user_id'] ?? ''; // ID user pengupload resep

                      // FutureBuilder untuk mengambil data user (nama & gambar profil)
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
                        builder: (context, userSnapshot) {
                          String authorName = 'Anonim'; // Default
                          String profilePicturePath = 'assets/images/profilemale.jpeg'; // Default asset

                          if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData && userSnapshot.data!.exists) {
                            final Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                            authorName = userData['nama'] ?? 'Anonim'; // Ambil nama dari koleksi 'users'
                            profilePicturePath = userData['profile_image_url'] ?? 'assets/images/profilemale.jpeg'; // Ambil URL gambar profil dari 'users'
                          }

                          // Data resep untuk _buildRecipeCard
                          final String nama = recipeData['nama'] ?? 'Nama Resep Tidak Tersedia';
                          final String deskripsi = recipeData['deskripsi'] ?? 'Deskripsi tidak tersedia';
                          final String rating = (recipeData['rating'] is num) ? recipeData['rating'].toString() : 'N/A';
                          final String waktuMasak = recipeData['waktu_masak'] ?? 'N/A';
                          final String imageUrl = recipeData['image_url'] ?? 'assets/images/default.png';

                          return GestureDetector(
                            onTap: () {
                              // Navigasi ke DetailResepPage dengan ID dokumen resep
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailResepPage(
                                    documentId: documentId,
                                  ),
                                ),
                              );
                            },
                            child: _buildRecipeCard(
                              imagePath: imageUrl,
                              rating: rating,
                              title: nama,
                              description: deskripsi,
                              author: authorName, // Menggunakan nama penulis dari koleksi 'users'
                              time: waktuMasak,
                              profileImagePath: profilePicturePath, // Menggunakan gambar profil dari koleksi 'users'
                              onBookmarkTap: () {
                                // Memanggil method bookmarkRecipe saat ikon bookmark diklik
                                _bookmarkRecipe(documentId, recipeData);
                              },
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
      // Bottom Navigation Bar
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0, // Indeks halaman saat ini (Home)
        onTap: (index) {
          // Navigasi ke halaman-halaman lain berdasarkan indeks navbar
          switch (index) {
            case 0:
            // Home - sudah di halaman ini
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResepkuPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkPage()),
              );
              break;
            case 4:
            // Profil - belum ada halaman, lewati
              break;
          }
        },
      ),
    );
  }

  // Widget helper untuk membuat kartu banner di carousel
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

  // Widget helper untuk membuat kartu resep di grid
  Widget _buildRecipeCard({
    required String imagePath,
    required String rating,
    required String title,
    required String description,
    required String author,
    required String time,
    required String profileImagePath,
    required VoidCallback onBookmarkTap, // Callback untuk aksi bookmark
  }) {
    // Logika untuk menentukan apakah gambar adalah Network, Local File, atau Asset
    final bool isNetworkImage = imagePath.startsWith('http');
    final bool isLocalFileImage = imagePath.startsWith('/data/user/') || imagePath.startsWith('/storage/emulated/') || imagePath.startsWith('file:///');

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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar Resep
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: isNetworkImage
                    ? Image.network(
                        imagePath,
                        height: 90.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading network image: $imagePath, Error: $error");
                          return Image.asset(
                            'assets/images/default.png',
                            height: 90.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : isLocalFileImage
                        ? Image.file(
                            File(imagePath),
                            height: 90.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading local file image: $imagePath, Error: $error");
                              return Image.asset(
                                'assets/images/default.png',
                                height: 90.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            imagePath,
                            height: 90.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading asset image: $imagePath, Error: $error");
                              return Image.asset(
                                'assets/images/default.png',
                                height: 90.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
              ),
            ),
          ),
          // Konten Teks Resep
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
                        Icon(Icons.star, color: Color(0xFF662B0E), size: 14.0),
                        SizedBox(width: 3.0),
                        Text(
                          rating,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF662B0E),
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                    // Icon Bookmark yang bisa diklik
                    GestureDetector(
                      onTap: onBookmarkTap, // Memanggil callback saat diklik
                      child: Icon(
                        Icons.bookmark_border, // Anda bisa mengubah ini menjadi Icons.bookmark_fill jika sudah dibookmark (perlu state dan cek Firestore)
                        color: Color(0xFF662B0E),
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                    color: Color(0xFF662B0E),
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  description,
                  style: TextStyle(fontSize: 10.0, color: Color(0xFF662B0E)),
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14.0),
                // Informasi Penulis dan Waktu Memasak
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9.0,
                      // Logika untuk gambar profil dari network atau asset
                      backgroundImage: profileImagePath.startsWith('http')
                          ? NetworkImage(profileImagePath) as ImageProvider
                          : AssetImage(profileImagePath),
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Color(0xFF662B0E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 228, 194, 1),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
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