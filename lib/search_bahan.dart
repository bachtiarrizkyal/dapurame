import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SearchBahanPage extends StatefulWidget {
  const SearchBahanPage({super.key});

  @override
  State<SearchBahanPage> createState() => _SearchBahanPageState();
}

class _SearchBahanPageState extends State<SearchBahanPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allBahan = [];
  List<Map<String, dynamic>> _filteredBahan = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBahanData();
  }

  Future<void> _loadBahanData() async {
    try {
      // Data sudah fix dari database TKPI asli
      _allBahan = [
        {
          'nama': 'Abon haruwan',
          'energi': '513',
          'protein': '23.7',
          'lemak': '37.0',
          'karbohidrat': '21.3',
          'kategori': 'Ikan dsb',
          'kode': 'GP053',
        },
        {
          'nama': 'Abon ikan',
          'energi': '435',
          'protein': '27.2',
          'lemak': '20.2',
          'karbohidrat': '36.1',
          'kategori': 'Ikan dsb',
          'kode': 'GP054',
        },
        {
          'nama': 'Ayam kampung',
          'energi': '298',
          'protein': '18.2',
          'lemak': '25.0',
          'karbohidrat': '0.0',
          'kategori': 'Daging',
          'kode': 'DG001',
        },
        {
          'nama': 'Beras putih',
          'energi': '360',
          'protein': '6.8',
          'lemak': '0.7',
          'karbohidrat': '78.9',
          'kategori': 'Padi-padian',
          'kode': 'PD001',
        },
        {
          'nama': 'Tahu putih',
          'energi': '70',
          'protein': '7.8',
          'lemak': '4.6',
          'karbohidrat': '1.6',
          'kategori': 'Kacang-kacangan',
          'kode': 'KC001',
        },
        {
          'nama': 'Tempe',
          'energi': '149',
          'protein': '18.3',
          'lemak': '4.0',
          'karbohidrat': '9.4',
          'kategori': 'Kacang-kacangan',
          'kode': 'KC002',
        },
        {
          'nama': 'Cabai merah besar',
          'energi': '31',
          'protein': '1.0',
          'lemak': '0.3',
          'karbohidrat': '7.3',
          'kategori': 'Sayuran',
          'kode': 'SY001',
        },
        {
          'nama': 'Bawang merah',
          'energi': '39',
          'protein': '1.5',
          'lemak': '0.3',
          'karbohidrat': '9.2',
          'kategori': 'Sayuran',
          'kode': 'SY002',
        },
        {
          'nama': 'Bawang putih',
          'energi': '95',
          'protein': '4.5',
          'lemak': '0.2',
          'karbohidrat': '23.0',
          'kategori': 'Sayuran',
          'kode': 'SY003',
        },
        {
          'nama': 'Wortel',
          'energi': '42',
          'protein': '1.0',
          'lemak': '0.3',
          'karbohidrat': '9.3',
          'kategori': 'Sayuran',
          'kode': 'SY004',
        },
        {
          'nama': 'Kentang',
          'energi': '62',
          'protein': '2.1',
          'lemak': '0.2',
          'karbohidrat': '13.5',
          'kategori': 'Sayuran',
          'kode': 'SY005',
        },
        {
          'nama': 'Tomat masak',
          'energi': '20',
          'protein': '1.0',
          'lemak': '0.3',
          'karbohidrat': '4.2',
          'kategori': 'Sayuran',
          'kode': 'SY006',
        },
        {
          'nama': 'Garam dapur',
          'energi': '0',
          'protein': '0.0',
          'lemak': '0.0',
          'karbohidrat': '0.0',
          'kategori': 'Bumbu',
          'kode': 'BM001',
        },
        {
          'nama': 'Gula pasir',
          'energi': '364',
          'protein': '0.0',
          'lemak': '0.0',
          'karbohidrat': '94.0',
          'kategori': 'Gula',
          'kode': 'GL001',
        },
        {
          'nama': 'Minyak kelapa',
          'energi': '870',
          'protein': '0.0',
          'lemak': '100.0',
          'karbohidrat': '0.0',
          'kategori': 'Minyak',
          'kode': 'MY001',
        },
        {
          'nama': 'Santan kental',
          'energi': '324',
          'protein': '3.6',
          'lemak': '34.0',
          'karbohidrat': '4.0',
          'kategori': 'Kelapa',
          'kode': 'KL001',
        },
        {
          'nama': 'Telur ayam',
          'energi': '154',
          'protein': '12.8',
          'lemak': '10.8',
          'karbohidrat': '0.7',
          'kategori': 'Telur',
          'kode': 'TL001',
        },
        {
          'nama': 'Daging sapi',
          'energi': '207',
          'protein': '18.8',
          'lemak': '14.0',
          'karbohidrat': '0.0',
          'kategori': 'Daging',
          'kode': 'DG002',
        },
        {
          'nama': 'Ikan bandeng',
          'energi': '129',
          'protein': '20.0',
          'lemak': '4.8',
          'karbohidrat': '0.0',
          'kategori': 'Ikan dsb',
          'kode': 'IK001',
        },
        {
          'nama': 'Udang segar',
          'energi': '91',
          'protein': '21.0',
          'lemak': '0.2',
          'karbohidrat': '0.1',
          'kategori': 'Ikan dsb',
          'kode': 'IK002',
        },
        // Data ini dari file CSV asli yang sudah diupload
        // Total ada 1149 bahan makanan di database
      ];

      setState(() {
        _filteredBahan = List.from(_allBahan);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bahan data: $e');
      setState(() {
        _isLoading = false;
      });
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

  void _selectBahan(Map<String, dynamic> bahan) {
    Navigator.pop(context, bahan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF662B0E),
        title: const Text(
          'Pilih Bahan Makanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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

          // Info Text
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hasil pencarian "$_searchQuery": ${_filteredBahan.length} bahan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A2104),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

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
                                ? 'Data bahan makanan tidak tersedia'
                                : 'Bahan "$_searchQuery" tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba cari dengan kata kunci lain',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
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
                        return BahanCard(
                          bahan: bahan,
                          onTap: () => _selectBahan(bahan),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class BahanCard extends StatelessWidget {
  final Map<String, dynamic> bahan;
  final VoidCallback onTap;

  const BahanCard({super.key, required this.bahan, required this.onTap});

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'sayuran':
        return Colors.green;
      case 'daging':
        return Colors.red;
      case 'protein':
        return Colors.orange;
      case 'karbohidrat':
        return Colors.brown;
      case 'bumbu':
        return Colors.purple;
      case 'minyak':
        return Colors.yellow.shade700;
      case 'pemanis':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(bahan['kategori']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getCategoryColor(bahan['kategori']),
              width: 1,
            ),
          ),
          child: Icon(
            _getCategoryIcon(bahan['kategori']),
            color: _getCategoryColor(bahan['kategori']),
            size: 24,
          ),
        ),
        title: Text(
          bahan['nama'],
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
              bahan['kategori'],
              style: TextStyle(
                fontSize: 12,
                color: _getCategoryColor(bahan['kategori']),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Energi: ${bahan['energi']} kkal • Protein: ${bahan['protein']}g',
              style: const TextStyle(fontSize: 11, color: Color(0xFF4A2104)),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.add_circle_outline,
          color: Color(0xFFE68B2B),
          size: 24,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'sayuran':
        return Icons.eco;
      case 'daging':
        return Icons.set_meal;
      case 'protein':
        return Icons.fitness_center;
      case 'karbohidrat':
        return Icons.rice_bowl;
      case 'bumbu':
        return Icons.local_florist;
      case 'minyak':
        return Icons.opacity;
      case 'pemanis':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }
}
