// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navbar.dart';
import 'resepku.dart';
import 'bookmark.dart';
import 'nutrisi.dart';
import 'notification_page.dart';
import 'profile.dart'; // <-- 1. IMPOR HALAMAN PROFIL YANG BARU

// Fungsi main() sebaiknya berada di file terpisah (main.dart),
// tapi untuk sementara kita biarkan di sini.
void main() {
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
      home: HomePage(), // Mulai dari HomePage sebagai induk
    ),
  );
}

// HomePage sekarang menjadi "Induk" atau "Shell" untuk navigasi
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk menyimpan index halaman yang sedang aktif
  int _currentIndex = 0;

  // 2. BUAT DAFTAR HALAMAN SESUAI URUTAN NAVBAR
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
      // 3. BODY SEKARANG MENAMPILKAN HALAMAN DARI DAFTAR DI ATAS
      //    BERDASARKAN `_currentIndex`
      body: _pages[_currentIndex],

      // 4. NAVBAR MENGGUNAKAN LOGIKA BARU YANG LEBIH EFISIEN
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

// ------------------------------------------------------------------
// WIDGET BARU UNTUK KONTEN KHUSUS HALAMAN HOME
// Semua kode UI Home Anda yang lama dipindahkan ke sini.
// ------------------------------------------------------------------
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              // Bagian Header (Halo, Wanda! & Notifikasi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Halo, Wanda!', // Nanti ini bisa kita buat dinamis
                    style: TextStyle(
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

              // Carousel Banner
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

              // Grid Resep Paling Diminati
              const Text(
                'Paling Diminati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: 6, // Sesuaikan dengan jumlah resep
                itemBuilder: (context, index) {
                  final List<Map<String, String>> recipes = [
                    {
                      'imagePath': 'assets/images/risolmayo.jpeg',
                      'rating': '9.2',
                      'title': 'Risol Mayo',
                      'description':
                          'Risol mayo adalah jajanan tradisional berbentuk gulungan...',
                      'author': 'Maul - ITS',
                      'time': '20 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/nasipadang.jpg',
                      'rating': '9.5',
                      'title': 'Nasi Padang',
                      'description':
                          'Nasi Padang adalah makanan khas Minangkabau...',
                      'author': 'Zumar - ITS',
                      'time': '25 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/rawon.jpeg',
                      'rating': '8.7',
                      'title': 'Nasi Rawon',
                      'description':
                          'Rawon adalah masakan sup daging sapi berkuah hitam...',
                      'author': 'Cindy - Unair',
                      'time': '15 mins',
                      'profileImagePath': 'assets/images/profilefemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahubakso.jpg',
                      'rating': '8.5',
                      'title': 'Tahu Bakso',
                      'description':
                          'Tahu Bakso adalah kuliner asal Semarang...',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahu-tek.jpeg',
                      'rating': '8.9',
                      'title': 'Tahu Tek',
                      'description':
                          'Tahu Tek adalah kuliner yang terdiri dari tahu goreng...',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/sushi.jpg',
                      'rating': '9.5',
                      'title': 'Sushi',
                      'description':
                          'Sushi adalah makanan Jepang yang terdiri dari nasi...',
                      'author': 'Rony - Ubaya',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                  ];
                  final recipe = recipes[index];
                  return _buildRecipeCard(
                    imagePath: recipe['imagePath']!,
                    rating: recipe['rating']!,
                    title: recipe['title']!,
                    description: recipe['description']!,
                    author: recipe['author']!,
                    time: recipe['time']!,
                    profileImagePath: recipe['profileImagePath']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk banner dan resep tidak perlu diubah
  Widget _buildBannerCard({
    required String image,
    required String tag,
    required String title,
  }) {
    // ... (kode banner card Anda yang lama)
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

  Widget _buildRecipeCard({
    required String imagePath,
    required String rating,
    required String title,
    required String description,
    required String author,
    required String time,
    required String profileImagePath,
  }) {
    // ... (kode recipe card Anda yang lama)
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
                child: Image.asset(
                  imagePath,
                  height: 90.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                    Icon(
                      Icons.bookmark_border,
                      color: Color(0xFF662B0E),
                      size: 18.0,
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9.0,
                      backgroundImage: AssetImage(profileImagePath),
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
