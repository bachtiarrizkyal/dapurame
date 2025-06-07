import 'package:flutter/material.dart';
import 'bookmark.dart';

class BookmarkDetailPage extends StatelessWidget {
  final String imagePath;
  final String title;

  const BookmarkDetailPage({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final int rating = 4;

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
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              'assets/images/profilewanda.jpg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Wanda • 01/06/2025',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2104),
                                ),
                              ),
                              Text(
                                '@wandaarma',
                                style: TextStyle(
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Tahu Bakso',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2104),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.edit,
                                color: Color(0xFFE68B2B),
                                size: 20,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEACC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 18,
                                  color: Color(0xFFE68B2B),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "30 min",
                                  style: TextStyle(color: Color(0xFF4A2104)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
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
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Camilan gurih yang terdiri dari tahu yang diisi dengan adonan bakso, kemudian dikukus atau digoreng hingga matang.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A2104),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("Bahan - Bahan"),
                      _bulletText("1 buah tahu putih"),
                      _bulletText("250gr campuran daging ayam dan sapi"),
                      _bulletText("2 siung bawang putih"),
                      _bulletText("1 batang daun bawang"),
                      _bulletText("Garam, merica, penyedap secukupnya"),
                      const SizedBox(height: 16),
                      _sectionTitle("Cara Membuat"),
                      _bulletText("Campur semua bahan hingga rata."),
                      _bulletText("Isi bagian tengah tahu dengan adonan."),
                      _bulletText("Kukus atau goreng hingga matang."),
                      const SizedBox(height: 16),
                      _sectionTitle("Catatan Pribadi"),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Masukkan Catatan',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB7B7B7),
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(
                                0xFFE68B2B,
                              ), 
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A2104),
                              width: 1,
                            ),
                          ),
                        ),
                        maxLines: 3,
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BookmarkPage()),
                );
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
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF4A2104),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.edit, color: Color(0xFFE68B2B), size: 20),
      ],
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4A2104),
        ),
      ),
    );
  }
}
