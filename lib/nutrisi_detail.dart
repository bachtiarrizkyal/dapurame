import 'package:flutter/material.dart';

class NutrisiDetailPage extends StatelessWidget {
  final Map<String, dynamic> bahan;

  const NutrisiDetailPage({
    super.key,
    required this.bahan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF662B0E),
        title: const Text(
          'Kandungan Nutrisi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bahan['nama'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getKelompokColor(bahan['kelompok']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getKelompokColor(bahan['kelompok']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          bahan['kelompok'],
                          style: TextStyle(
                            fontSize: 12,
                            color: _getKelompokColor(bahan['kelompok']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kode: ${bahan['kode']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A2104),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'per 100 g',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE68B2B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nutrisi Makro
            _buildSection(
              'Kandungan Makro',
              [
                _buildNutrisiRow('Air (Water)', bahan['air'], 'g'),
                _buildNutrisiRow('Energi (Energy)', bahan['energi'], 'Kal'),
                _buildNutrisiRow('Protein', bahan['protein'], 'g'),
                _buildNutrisiRow('Lemak (Fat)', bahan['lemak'], 'g'),
                _buildNutrisiRow('Karbohidrat (CHO)', bahan['karbohidrat'], 'g'),
                _buildNutrisiRow('Serat (Fiber)', bahan['serat'], 'g'),
                _buildNutrisiRow('Abu (Ash)', bahan['abu'], 'g'),
              ],
            ),

            const SizedBox(height: 16),

            // Mineral
            _buildSection(
              'Mineral',
              [
                _buildNutrisiRow('Kalsium (Ca)', bahan['kalsium'], 'mg'),
                _buildNutrisiRow('Fosfor (P)', bahan['fosfor'], 'mg'),
                _buildNutrisiRow('Besi (Fe)', bahan['besi'], 'mg'),
                _buildNutrisiRow('Natrium (Na)', bahan['natrium'], 'mg'),
                _buildNutrisiRow('Kalium (K)', bahan['kalium'], 'mg'),
                _buildNutrisiRow('Tembaga (Cu)', bahan['tembaga'], 'mg'),
                _buildNutrisiRow('Seng (Zn)', bahan['seng'], 'mg'),
              ],
            ),

            const SizedBox(height: 16),

            // Vitamin
            _buildSection(
              'Vitamin',
              [
                _buildNutrisiRow('Retinol (Vit. A)', bahan['retinol'], 'mcg'),
                _buildNutrisiRow('β-Karoten', bahan['karoten'], 'mcg'),
                _buildNutrisiRow('Thiamin (Vit. B1)', bahan['thiamin'], 'mg'),
                _buildNutrisiRow('Riboflavin (Vit. B2)', bahan['riboflavin'], 'mg'),
                _buildNutrisiRow('Niasin', bahan['niasin'], 'mg'),
                _buildNutrisiRow('Vitamin C', bahan['vitamin_c'], 'mg'),
              ],
            ),

            const SizedBox(height: 16),

            // Info Tambahan
            _buildSection(
              'Informasi Lainnya',
              [
                _buildNutrisiRow('BDD (Bagian Dapat Dimakan)', bahan['bdd'], '%'),
                _buildNutrisiRow('Jenis Bahan Makanan', bahan['jenis'], ''),
                _buildNutrisiRow('Kelompok Makanan', bahan['kelompok'], ''),
              ],
            ),

            const SizedBox(height: 20),

            // Footer Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE68B2B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE68B2B).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keterangan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Data berdasarkan TKPI (Tabel Komposisi Pangan Indonesia) 2018\n• Nilai "-" menunjukkan data tidak tersedia\n• BDD = Bagian yang Dapat Dimakan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      default:
        return Colors.grey;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF662B0E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrisiRow(String nama, dynamic nilai, String satuan) {
    String displayValue = nilai?.toString() ?? '-';
    if (displayValue.isEmpty || displayValue == 'null' || displayValue == 'NaN') {
      displayValue = '-';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A2104),
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue == '-' ? '-' : '$displayValue $satuan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: displayValue == '-' 
                    ? Colors.grey 
                    : const Color(0xFF4A2104),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}