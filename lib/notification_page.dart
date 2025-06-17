import 'package:flutter/material.dart';

// Halaman Notifikasi (Sama seperti kode sebelumnya, hanya dipindahkan ke file ini)
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAF2),
      appBar: AppBar(
        backgroundColor: Color(0xFF662B0E),
         iconTheme: const IconThemeData(
          color: Colors.white, // Ini akan mengubah warna tombol back
        ),

        titleTextStyle: const TextStyle(
          color: Colors.white, // Ini akan mengubah warna tulisan "Notifikasi"
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Ini akan menutup halaman saat ini dan kembali ke halaman sebelumnya (HomePage)
            Navigator.pop(context);
          },
        ),
        title: const Text('Notifikasi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFFAF2),
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFFFFFAF2), width: 2.0),
          ),
          tabs: const [
            Tab(text: 'Umum'),
            Tab(text: 'Resep Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralNotifications(),
          const Center(child: Text('Tidak ada notifikasi resep.')),
        ],
      ),
    );
  }

  // ... (Salin semua method helper _buildGeneralNotifications dan _buildNotificationTile ke sini)
  // Method helper _buildGeneralNotifications
  Widget _buildGeneralNotifications() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hari ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF662B0E)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildNotificationTile(
                  avatar: const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                  ),
                  message: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF662B0E), fontSize: 14, fontFamily: 'Poppins'),
                      children: [
                        TextSpan(text: 'Maul', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' membuat resep baru'),
                      ],
                    ),
                  ),
                  time: '10 menit',
                ),
                const Divider(indent: 16, endIndent: 16),
                _buildNotificationTile(
                  avatar: const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=2'),
                  ),
                  message: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF662B0E), fontSize: 14, fontFamily: 'Poppins'),
                      children: [
                        TextSpan(text: 'Rani', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' menyimpan resep kamu'),
                      ],
                    ),
                  ),
                  time: '20 menit',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Kemarin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF662B0E)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildNotificationTile(
              avatar: SizedBox(
                width: 50,
                height: 40,
                child: Stack(
                  children: const [
                    CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                    ),
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=4'),
                      ),
                    ),
                  ],
                ),
              ),
              message: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF662B0E), fontSize: 14, fontFamily: 'Poppins'),
                  children: [
                    TextSpan(text: 'Maul, Rani, dan 2 lainnya', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' menyimpan resep kamu'),
                  ],
                ),
              ),
              time: '17/06/2025',
            ),
          ),
        ],
      ),
    );
  }

  // Method helper _buildNotificationTile
  Widget _buildNotificationTile({
    required Widget avatar,
    required Widget message,
    required String time,
  }) {
    return ListTile(
      leading: avatar,
      title: message,
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      dense: true,
    );
  }
}