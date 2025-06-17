import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'nutrisi_detail.dart';
import 'resepku.dart';
import 'bookmark.dart';

class NutrisiPage extends StatefulWidget {
  const NutrisiPage({super.key});

  @override
  State<NutrisiPage> createState() => _NutrisiPageState();
}

class _NutrisiPageState extends State<NutrisiPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allBahan = [];
  List<Map<String, dynamic>> _filteredBahan = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNutrisiData();
  }

  Future<void> _loadNutrisiData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Loading nutrisi data from Firestore...');

      // Load data from Firestore collection 'nutrisi'
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('nutrisi').get();

      List<Map<String, dynamic>> loadedData = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add document ID as kode if not present
        data['kode'] = data['kode'] ?? doc.id;
        data['no'] = loadedData.length + 1; // Generate number

        // Debug individual documents
        print(
          '📄 Document ${doc.id}: ${data['nama']} - ${data['energi']} kkal',
        );

        loadedData.add(data);
      }

      print(
        '✅ Successfully loaded ${loadedData.length} nutrisi items from Firestore',
      );

      // Check if data is actually loaded
      if (loadedData.isEmpty) {
        print('⚠️ No data found in Firestore collection "nutrisi"');
      }

      setState(() {
        _allBahan = loadedData;
        _filteredBahan = List.from(_allBahan);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR loading nutrisi data from Firestore: $e');

      setState(() {
        _allBahan = [];
        _filteredBahan = [];
        _isLoading = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data nutrisi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _filterBahan(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBahan = List.from(_allBahan);
      } else {
        _filteredBahan =
            _allBahan
                .where(
                  (bahan) =>
                      bahan['nama'].toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _navigateToDetail(Map<String, dynamic> bahan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NutrisiDetailPage(bahan: bahan)),
    );
  }

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
            'Nutrisi',
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Info Box
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE68B2B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE68B2B).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Data kandungan nutrisi makanan berikut berdasarkan Tabel Komposisi Pangan Indonesia (TKPI) 2018 oleh Kementerian Kesehatan RI per 100 gram BDD (Bagian yang dapat dimakan).',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4A2104),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade200),
                color: Colors.white,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBahan,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF662B0E)),
                  hintText: 'Cari bahan makanan...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB7B7B7),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Header Table
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF662B0E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Nama Bahan Makanan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bahan List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE68B2B),
                      ),
                    )
                    : _filteredBahan.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Data nutrisi tidak tersedia'
                                : 'Bahan "$_searchQuery" tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredBahan.length,
                      itemBuilder: (context, index) {
                        final bahan = _filteredBahan[index];
                        return NutrisiCard(
                          no: bahan['no'],
                          nama: bahan['nama']?.toString() ?? 'Unknown',
                          kelompok: bahan['kelompok']?.toString() ?? 'Lainnya',
                          energi: bahan['energi']?.toString() ?? '0',
                          protein: bahan['protein']?.toString() ?? '0',
                          onTap: () => _navigateToDetail(bahan),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 1,
        onTap: (index) {
          // Navigate to different pages
          switch (index) {
            case 0:
              // Home - belum ada halaman, skip
              break;
            case 1:
              // Nutrisi - already here
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class NutrisiCard extends StatelessWidget {
  final int no;
  final String nama;
  final String kelompok;
  final String energi;
  final String protein;
  final VoidCallback onTap;

  const NutrisiCard({
    super.key,
    required this.no,
    required this.nama,
    required this.kelompok,
    required this.energi,
    required this.protein,
    required this.onTap,
  });

  Color _getKelompokColor(String kelompok) {
    switch (kelompok.toLowerCase()) {
      case 'sayuran':
        return Colors.green;
      case 'daging':
        return Colors.red;
      case 'ikan dsb':
        return Colors.blue;
      case 'kacang-kacangan':
        return Colors.orange;
      case 'padi-padian':
        return Colors.brown;
      case 'telur':
        return Colors.yellow.shade700;
      case 'serealia':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _getKelompokColor(kelompok).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _getKelompokColor(kelompok), width: 1),
          ),
          child: Center(
            child: Text(
              '$no',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getKelompokColor(kelompok),
              ),
            ),
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A2104),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kelompok,
              style: TextStyle(
                fontSize: 11,
                color: _getKelompokColor(kelompok),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Energi: $energi kkal • Protein: ${protein}g',
              style: const TextStyle(fontSize: 10, color: Color(0xFF4A2104)),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFE68B2B),
          size: 16,
        ),
      ),
    );
  }
}
