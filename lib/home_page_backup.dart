import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navbar.dart';
import 'resepku.dart';
import 'bookmark.dart';
import 'nutrisi.dart';
import 'notification_page.dart';

void main() {
  // Mengatur style status bar agar menyatu dengan desain
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Membuat background status bar transparan
      statusBarIconBrightness:
          Brightness.dark, // Membuat ikon (baterai, jam) menjadi hitam
    ),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan tulisan DEBUG di kanan atas
      home: HomePage(),
    ),
  );
}

// [DATA BARU] Untuk item di carousel horizontal
  final List<Map<String, String>> bannerItems = [
    {
      'image': 'assets/images/ramen.jpeg',
      'tag': 'Resep Terbaru!',
      'title': 'Ramen Ookamizu',
    },
    {
      'image': 'assets/images/sushi.jpg', // GAMBAR BARU
      'tag': 'Paling Favorit!',
      'title': 'Sushi Shinomiya',
    },
    {
      'image': 'assets/images/cake.jpg', // GAMBAR BARU
      'tag': 'Hidangan Penutup!',
      'title': 'Cake Berry',
    },
  ];

// ubah dari StatelessWidget menjadi StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

 @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  // Controller untuk PageView
  final PageController _pageController = PageController();

  // Jangan lupa dispose controller saat widget tidak lagi digunakan
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, Wanda!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900, // Adjusted font weight
                      color: Color(0xFF8B4513), // Saddle Brown color
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: Color(0xFF8B4513),
                    ), // Saddle Brown color
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationPage()),
                      );
                    },
                  ),
                ],
              ),
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
                        fontWeight: FontWeight.bold, // Dipertebal
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Resep',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ), // Added hint text style
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF8B4513),
                        ), // Changed search icon color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF8B4513)),
                        ),
                        filled: true,
                        fillColor: Color(0xFFFFFAF2), // Beige color
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF8B4513), // Saddle Brown color
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
              
              // Memberi jarak antara container atas dan gambar ramen
              SizedBox(height: 24.0),

              // Mengganti ListView dengan PageView.builder
               SizedBox(
                height: 200.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerItems.length,
                  // Callback ini akan terpanggil setiap kali halaman berganti
                  onPageChanged: (index) {
                    // Perbarui state dengan indeks baru, UI akan otomatis rebuild
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = bannerItems[index];
                    // Tambahkan padding di sini agar ada jarak antar item
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
              // Dot Indicator yang interaktif
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bannerItems.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      // Warna ditentukan oleh state _currentPageIndex
                      color: _currentPageIndex == index
                          ? Color(0xFF8B4513) // Warna aktif
                          : Color.fromRGBO(230, 139, 43, 0.5), // Warna non-aktif
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              
              SizedBox(height: 26.0),
          
              Text(
                'Paling Diminati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900, // Adjusted font weight
                  color: Color(0xFF8B4513), // Saddle Brown color
                ),
              ),
              SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.65, // Adjusted to give more vertical space
                ),
                itemCount: 6, // Number of recipe cards
                itemBuilder: (context, index) {
                  final List<Map<String, String>> recipes = [
                    {
                      'imagePath': 'assets/images/risolmayo.jpeg',
                      'rating': '9.2',
                      'title': 'Risol Mayo',
                      'description':
                          'Risol mayo adalah jajanan tradisional berbentuk gulungan yang memiliki berbagai...',
                      'author': 'Maul - ITS',
                      'time': '20 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/nasipadang.jpg',
                      'rating': '9.5',
                      'title': 'Nasi Padang',
                      'description':
                          'Nasi Padang adalah makanan khas Minangkabau yang berupa nasi putih yang disajikan dengan berbagai macam',
                      'author': 'Zumar - ITS',
                      'time': '25 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/rawon.jpeg',
                      'rating': '8.7',
                      'title': 'Nasi Rawon',
                      'description':
                          'Rawon adalah masakan sup daging sapi berkuah hitam yang merupakan hidangan khas Surabaya.',
                      'author': 'Cindy - Unair',
                      'time': '15 mins',
                      'profileImagePath': 'assets/images/profilefemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahubakso.jpg',
                      'rating': '8.5',
                      'title': 'Tahu Bakso',
                      'description':
                          'Tahu Bakso adalah kuliner asal Semarang yang dibuat dari tahu yang tengahnya diberi isi bakso.',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahu-tek.jpeg',
                      'rating': '8.9',
                      'title': 'Tahu Tek',
                      'description':
                          'Tahu Tek adalah kuliner yang terdiri dari tahu goreng, lontong, kentang, dan sedikit taoge yang disiram...',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/sushi.jpg',
                      'rating': '9.5',
                      'title': 'Sushi',
                      'description':
                          'Sushi adalah makanan Jepang yang terdiri dari nasi yang dibentuk bersama lauk (neta) berupa makanan laut, daging, sayuran bakar atau sudah dimasak.',
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
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0,
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
              // Home - already here
              break;
            case 1:
              // Nutrisi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
              // Resepku
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResepkuPage()),
              );
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

  // Untuk membuat satu item di carousel
  Widget _buildBannerCard({
    required String image, 
    required String tag, 
    required String title
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
        )
      ],
    ),
    // Gunakan ClipRRect untuk memastikan semua anak (gambar & gradasi)
    // ikut terpotong sesuai bentuk rounded corner.
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        fit: StackFit.expand, // Agar semua anak Stack mengisi ruang
        children: [
          // LAPISAN 1: GAMBAR (paling bawah)
          Image.asset(
            image,
            fit: BoxFit.cover,
          ),

          // LAPISAN 2: GRADASI BAYANGAN (di tengah)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0], // Bayangan baru mulai dari 40% atas
              ),
            ),
          ),
          // ==========================================================

          // LAPISAN 3: TAG (paling atas)
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

          // LAPISAN 4: JUDUL (paling atas)
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                // Shadow pada teks bisa dipertahankan atau dihapus
                // karena sudah dibantu oleh gradasi background.
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(2.0, 2.0),
                  )
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

      // Langsung ke kontennya
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Membuat tinggi kartu pas dengan kontennya
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar (Tidak berubah)
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

          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(
              12.0,
            ), // Beri padding seragam di sekeliling konten teks
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

                // Ganti Spacer() kembali menjadi SizedBox untuk jarak yang pasti
                SizedBox(height: 14.0,),
                
                // Baris Avatar dan Waktu
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


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapurame/nutrisi.dart';
import 'package:dapurame/resepku.dart';
import 'package:dapurame/bookmark.dart';
import 'navbar.dart';
import 'resepku.dart';
import 'bookmark.dart';
import 'nutrisi.dart';
import 'notification_page.dart';
import 'dart:io'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, 
    ),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, 
      home: HomePage(),
    ),
  );
}

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, Wanda!',
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
                            builder: (context) => const NotificationPage()),
                      );
                    },
                  ),
                ],
              ),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Resep',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
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
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.0),

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

              Text(
                'Paling Diminati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resep')
                    .where('upload', isEqualTo: true)
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
                    return Center(child: Text('Tidak ada resep yang diunggah.'));
                  }

                  final recipes = snapshot.data!.docs;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio:
                          0.65,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeData = recipes[index].data() as Map<String, dynamic>;
                      final String nama = recipeData['nama'] ?? 'Nama Resep Tidak Tersedia';
                      final String deskripsi = recipeData['deskripsi'] ?? 'Deskripsi tidak tersedia';
                      final String rating = (recipeData['rating'] is num) ? recipeData['rating'].toString() : 'N/A';
                      final String waktuMasak = recipeData['waktu_masak'] ?? 'N/A';
                      final String imageUrl = recipeData['image_url'] ?? 'assets/images/default.png';

                      final String author = recipeData['author'] ?? 'Penulis Anonim'; 
                      final String profileImagePath = recipeData['profile_image_path'] ?? 'assets/images/profilemale.jpeg'; 


                      return _buildRecipeCard(
                        imagePath: imageUrl,
                        rating: rating,
                        title: nama,
                        description: deskripsi,
                        author: author,
                        time: waktuMasak,
                        profileImagePath: profileImagePath,
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0,
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
            // Home - already here
              break;
            case 1:
            // Nutrisi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
            // Resepku
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResepkuPage()),
              );
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
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // LAPISAN 1: GAMBAR (paling bawah)
            Image.asset(
              image,
              fit: BoxFit.cover,
            ),

            // LAPISAN 2: GRADASI BAYANGAN (di tengah)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                ),
              ),
            ),


            // LAPISAN 3: TAG (paling atas)
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

            // LAPISAN 4: JUDUL (paling atas)
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
                    )
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
        mainAxisSize:
            MainAxisSize.min,
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
                child: imagePath.startsWith('http')
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
                    : imagePath.startsWith('/data/user/') || imagePath.startsWith('/storage/emulated/') || imagePath.startsWith('file:///')
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

          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(
              12.0,
            ), 
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
                SizedBox(height: 4.0),
                Text(
                  description,
                  style: TextStyle(fontSize: 10.0, color: Color(0xFF662B0E)),
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14.0,),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navbar.dart';
import 'resepku.dart';
import 'bookmark.dart';
import 'nutrisi.dart';
import 'notification_page.dart';
import 'detail_resep.dart';

void main() {
  // Mengatur style status bar agar menyatu dengan desain
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Membuat background status bar transparan
      statusBarIconBrightness:
          Brightness.dark, // Membuat ikon (baterai, jam) menjadi hitam
      systemNavigationBarColor: Colors.white, // Navigation bar tidak berubah
    ),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan tulisan DEBUG di kanan atas
      home: HomePage(),
    ),
  );
}

// [DATA BARU] Untuk item di carousel horizontal
final List<Map<String, String>> bannerItems = [
  {
    'image': 'assets/images/ramen.jpeg',
    'tag': 'Resep Terbaru!',
    'title': 'Ramen Ookamizu',
  },
  {
    'image': 'assets/images/sushi.jpg', // GAMBAR BARU
    'tag': 'Paling Favorit!',
    'title': 'Sushi Shinomiya',
  },
  {
    'image': 'assets/images/cake.jpg', // GAMBAR BARU
    'tag': 'Hidangan Penutup!',
    'title': 'Cake Berry',
  },
];

// ubah dari StatelessWidget menjadi StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  // Controller untuk PageView
  final PageController _pageController = PageController();

  // Tambahkan state untuk bookmark
  List<Map<String, String>> bookmarkedRecipes = [];

  void _toggleBookmark(Map<String, String> recipe) {
    setState(() {
      if (bookmarkedRecipes.any((r) => r['title'] == recipe['title'])) {
        bookmarkedRecipes.removeWhere((r) => r['title'] == recipe['title']);
      } else {
        bookmarkedRecipes.add(recipe);
      }
    });
  }

  // Jangan lupa dispose controller saat widget tidak lagi digunakan
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, Wanda!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900, // Adjusted font weight
                      color: Color(0xFF8B4513), // Saddle Brown color
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: Color(0xFF8B4513),
                    ), // Saddle Brown color
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
                        fontWeight: FontWeight.bold, // Dipertebal
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Resep',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ), // Added hint text style
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF8B4513),
                        ), // Changed search icon color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF8B4513)),
                        ),
                        filled: true,
                        fillColor: Color(0xFFFFFAF2), // Beige color
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF8B4513), // Saddle Brown color
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

              // Memberi jarak antara container atas dan gambar ramen
              SizedBox(height: 24.0),

              // Mengganti ListView dengan PageView.builder
              SizedBox(
                height: 200.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerItems.length,
                  // Callback ini akan terpanggil setiap kali halaman berganti
                  onPageChanged: (index) {
                    // Perbarui state dengan indeks baru, UI akan otomatis rebuild
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = bannerItems[index];
                    // Tambahkan padding di sini agar ada jarak antar item
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
              // Dot Indicator yang interaktif
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bannerItems.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      // Warna ditentukan oleh state _currentPageIndex
                      color:
                          _currentPageIndex == index
                              ? Color(0xFF8B4513) // Warna aktif
                              : Color.fromRGBO(
                                230,
                                139,
                                43,
                                0.5,
                              ), // Warna non-aktif
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              SizedBox(height: 26.0),

              Text(
                'Paling Diminati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900, // Adjusted font weight
                  color: Color(0xFF8B4513), // Saddle Brown color
                ),
              ),
              SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio:
                      0.65, // Adjusted to give more vertical space
                ),
                itemCount: 6, // Number of recipe cards
                itemBuilder: (context, index) {
                  final List<Map<String, String>> recipes = [
                    {
                      'imagePath': 'assets/images/risolmayo.jpeg',
                      'rating': '9.2',
                      'title': 'Risol Mayo',
                      'description':
                          'Risol mayo adalah jajanan tradisional berbentuk gulungan yang memiliki berbagai...',
                      'author': 'Maul - ITS',
                      'time': '20 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/nasipadang.jpg',
                      'rating': '9.5',
                      'title': 'Nasi Padang',
                      'description':
                          'Nasi Padang adalah makanan khas Minangkabau yang berupa nasi putih yang disajikan dengan berbagai macam',
                      'author': 'Zumar - ITS',
                      'time': '25 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/rawon.jpeg',
                      'rating': '8.7',
                      'title': 'Nasi Rawon',
                      'description':
                          'Rawon adalah masakan sup daging sapi berkuah hitam yang merupakan hidangan khas Surabaya.',
                      'author': 'Cindy - Unair',
                      'time': '15 mins',
                      'profileImagePath': 'assets/images/profilefemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahubakso.jpg',
                      'rating': '8.5',
                      'title': 'Tahu Bakso',
                      'description':
                          'Tahu Bakso adalah kuliner asal Semarang yang dibuat dari tahu yang tengahnya diberi isi bakso.',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/tahu-tek.jpeg',
                      'rating': '8.9',
                      'title': 'Tahu Tek',
                      'description':
                          'Tahu Tek adalah kuliner yang terdiri dari tahu goreng, lontong, kentang, dan sedikit taoge yang disiram...',
                      'author': 'Ruli - ITS',
                      'time': '17 mins',
                      'profileImagePath': 'assets/images/profilemale.jpeg',
                    },
                    {
                      'imagePath': 'assets/images/sushi.jpg',
                      'rating': '9.5',
                      'title': 'Sushi',
                      'description':
                          'Sushi adalah makanan Jepang yang terdiri dari nasi yang dibentuk bersama lauk (neta) berupa makanan laut, daging, sayuran bakar atau sudah dimasak.',
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
                    isBookmarked: bookmarkedRecipes.any(
                      (r) => r['title'] == recipe['title'],
                    ),
                    onBookmarkTap: () => _toggleBookmark(recipe),
                    recipeData: recipe, // Pass the whole recipe map
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0,
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
              // Home - already here
              break;
            case 1:
              // Nutrisi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
              // Resepku
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResepkuPage()),
              );
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

  // Untuk membuat satu item di carousel
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
      // Gunakan ClipRRect untuk memastikan semua anak (gambar & gradasi)
      // ikut terpotong sesuai bentuk rounded corner.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          fit: StackFit.expand, // Agar semua anak Stack mengisi ruang
          children: [
            // LAPISAN 1: GAMBAR (paling bawah)
            Image.asset(image, fit: BoxFit.cover),

            // LAPISAN 2: GRADASI BAYANGAN (di tengah)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0], // Bayangan baru mulai dari 40% atas
                ),
              ),
            ),
            // ==========================================================

            // LAPISAN 3: TAG (paling atas)
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

            // LAPISAN 4: JUDUL (paling atas)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  // Shadow pada teks bisa dipertahankan atau dihapus
                  // karena sudah dibantu oleh gradasi background.
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
    required bool isBookmarked,
    required VoidCallback onBookmarkTap,
    required Map<String, String> recipeData,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailResepPage(recipe: recipeData),
          ),
        );
      },
      child: Container(
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

        // Langsung ke kontennya
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Membuat tinggi kartu pas dengan kontennya
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar (Tidak berubah)
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

            // Konten Teks
            Padding(
              padding: const EdgeInsets.all(
                12.0,
              ), // Beri padding seragam di sekeliling konten teks
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Color(0xFF662B0E),
                            size: 14.0,
                          ),
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
                      GestureDetector(
                        onTap: onBookmarkTap,
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
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

                  // Ganti Spacer() kembali menjadi SizedBox untuk jarak yang pasti
                  SizedBox(height: 14.0),

                  // Baris Avatar dan Waktu
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapurame/nutrisi.dart';
import 'package:dapurame/resepku.dart';
import 'package:dapurame/bookmark.dart';
import 'package:dapurame/detail_resep.dart';
import 'navbar.dart';
import 'notification_page.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, Wanda!',
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
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.0),

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bannerItems.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color:
                          _currentPageIndex == index
                              ? Color(0xFF8B4513)
                              : Color.fromRGBO(230, 139, 43, 0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              SizedBox(height: 26.0),

              Text(
                'Paling Diminati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('resep')
                        .where(
                          'is_shared',
                          isEqualTo: true,
                        ) // Pastikan field 'is_shared' sesuai dengan yang Anda gunakan untuk filter
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
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeDoc =
                          recipes[index]; // Ini adalah DocumentSnapshot
                      final recipeData =
                          recipeDoc.data() as Map<String, dynamic>;
                      final String documentId =
                          recipeDoc.id; // Ambil ID dokumen

                      final String nama =
                          recipeData['nama'] ?? 'Nama Resep Tidak Tersedia';
                      final String deskripsi =
                          recipeData['deskripsi'] ?? 'Deskripsi tidak tersedia';
                      final String rating =
                          (recipeData['rating'] is num)
                              ? recipeData['rating'].toString()
                              : 'N/A';
                      final String waktuMasak =
                          recipeData['waktu_masak'] ?? 'N/A';
                      final String imageUrl =
                          recipeData['image_url'] ??
                          'assets/images/default.png';

                      final String author =
                          recipeData['author'] ?? 'Penulis Anonim';
                      final String profileImagePath =
                          recipeData['profile_image_path'] ??
                          'assets/images/profilemale.jpeg';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailResepPage(
                                    documentId:
                                        documentId, // <--- KIRIM DOCUMENT ID SAJA
                                  ),
                            ),
                          );
                        },
                        child: _buildRecipeCard(
                          imagePath: imageUrl,
                          rating: rating,
                          title: nama,
                          description: deskripsi,
                          author: author,
                          time: waktuMasak,
                          profileImagePath: profileImagePath,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0,
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
              // Home - already here
              break;
            case 1:
              // Nutrisi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NutrisiPage()),
              );
              break;
            case 2:
              // Resepku
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ResepkuPage()),
              );
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
            // LAPISAN 1: GAMBAR (paling bawah)
            Image.asset(image, fit: BoxFit.cover),

            // LAPISAN 2: GRADASI BAYANGAN (di tengah)
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

            // LAPISAN 3: TAG (paling atas)
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

            // LAPISAN 4: JUDUL (paling atas)
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
                child:
                    imagePath.startsWith('http')
                        ? Image.network(
                          imagePath,
                          height: 90.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              "Error loading network image: $imagePath, Error: $error",
                            );
                            return Image.asset(
                              'assets/images/default.png',
                              height: 90.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : imagePath.startsWith('/data/user/') ||
                            imagePath.startsWith('/storage/emulated/') ||
                            imagePath.startsWith('file:///')
                        ? Image.file(
                          File(imagePath),
                          height: 90.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              "Error loading local file image: $imagePath, Error: $error",
                            );
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
                            print(
                              "Error loading asset image: $imagePath, Error: $error",
                            );
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

          // Konten Teks
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapurame/nutrisi.dart';
import 'package:dapurame/resepku.dart';
import 'package:dapurame/bookmark.dart';
import 'package:dapurame/detail_resep.dart';
import 'navbar.dart';
import 'notification_page.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, Wanda!',
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
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
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
              Text(
                'Resep Untuk Kamu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 16.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resep')
                    .where('is_shared', isEqualTo: true)
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
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipeDoc = recipes[index];
                      final recipeData = recipeDoc.data() as Map<String, dynamic>;
                      final String documentId = recipeDoc.id;

                      final String nama = recipeData['nama'] ?? 'Nama Resep Tidak Tersedia';
                      final String deskripsi = recipeData['deskripsi'] ?? 'Deskripsi tidak tersedia';
                      final String rating = (recipeData['rating'] is num) ? recipeData['rating'].toString() : 'N/A';
                      final String waktuMasak = recipeData['waktu_masak'] ?? 'N/A';
                      final String imageUrl = recipeData['image_url'] ?? 'assets/images/default.png';
                      final String userUid = recipeData['user_id'] ?? '';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
                        builder: (context, userSnapshot) {
                          String authorName = 'Anonim';
                          String profilePicturePath = 'assets/images/profilemale.jpeg'; 

                          if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData && userSnapshot.data!.exists) {
                            final Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                            authorName = userData['nama'] ?? 'Anonim'; 
                            profilePicturePath = userData['profile_image_url'] ?? 'assets/images/profilemale.jpeg';
                          }

                          return GestureDetector(
                            onTap: () {
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
                              author: authorName, 
                              time: waktuMasak,
                              profileImagePath: profilePicturePath,
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
      bottomNavigationBar: CustomNavbar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
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
              break;
          }
        },
      ),
    );
  }

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

  Widget _buildRecipeCard({
    required String imagePath,
    required String rating,
    required String title,
    required String description,
    required String author,
    required String time,
    required String profileImagePath,
  }) {
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