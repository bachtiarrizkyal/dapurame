// detail_resep.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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