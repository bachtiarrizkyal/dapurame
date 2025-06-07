import 'package:flutter/material.dart';
import 'navbar.dart';
import 'bookmarkdetail.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

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
            'Bookmark',
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF662B0E)),
                  hintText: 'Cari Produk',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB7B7B7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Bookmark List
            Expanded(
              child: ListView(
                children: const [
                  BookmarkCard(
                    imagePath: 'assets/images/tahubakso.jpg',
                    title: 'Tahu Bakso',
                    subtitle: 'Camilan gurih yang terdiri...',
                    rating: 4,
                  ),
                  BookmarkCard(
                    imagePath: 'assets/images/nasigoreng.jpeg',
                    title: 'Nasi Goreng',
                    subtitle: 'Cita rasa otentik khas Indonesia...',
                    rating: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 3, onTap: (index) {}),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final int rating;

  const BookmarkCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      BookmarkDetailPage(imagePath: imagePath, title: title),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 75,
            height: 68,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
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
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                color: Color(0xFF4A2104),
              ),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Color(0xFFE68B2B),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
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
          ],
        ),
        trailing: const Icon(Icons.delete, color: Color(0xFFE68B2B)),
      ),
    );
  }
}
