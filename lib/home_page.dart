import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navbar.dart';
import 'resepku.dart';
import 'bookmark.dart';
import 'nutrisi.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF2), // Changed background color to light beige
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
                      // Handle notification icon press
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
              SizedBox(height: 16.0),
              Stack(
                children: [
                  Container(
                    height: 200.0, // Adjust height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/ramen.jpeg',
                        ), // Placeholder image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          0xFFFFF2DF,
                        ), // A shade of red for the label
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        'Resep Terbaru!',
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                        ), // Adjusted font weight
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10.0,
                    right: 10.0,
                    child: Text(
                      'Ramen Ookamizu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color:
                          index == 0
                              ? Color(0xFF8B4513)
                              : Color.fromRGBO(
                                230,
                                139,
                                43,
                                1,
                              ), // Active dot color and inactive dot color
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
                  childAspectRatio: 0.7, // Adjusted to give more vertical space
                ),
                itemCount: 4, // Number of recipe cards
                itemBuilder: (context, index) {
                  final List<Map<String, String>> recipes = [
                    {
                      'imagePath': 'assets/images/risolmayo.jpeg',
                      'rating': '8.5',
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
                          'Tahu Bakso adalah kuliner yang terdiri dari tahu goreng, lontong, kentang, dan sedikit taoge yang disiram...',
                      'author': 'Ruli - ITS',
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
      // Kita tidak lagi butuh Column di sini karena strukturnya lebih sederhana
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
                SizedBox(
                  height: 14.0,
                ), // Anda bisa sesuaikan tingginya (misal: 12, 16, dll)
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
