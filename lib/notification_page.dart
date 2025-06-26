import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

// Inisialisasi plugin notifikasi di scope global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// =========================================================================
// Fungsi top-level untuk menangani notifikasi background
// HARUS DITANDAI DENGAN @pragma('vm:entry-point')
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Background Notification tapped from top-level function: ${notificationResponse.payload}');
  // Ini adalah tempat Anda akan menangani aksi saat notifikasi ditekan
  // ketika aplikasi di background atau ditutup.
  // Contoh: Navigasi ke halaman tertentu
  // Navigator.push(context, MaterialPageRoute(builder: (context) => SomePage(payload: notificationResponse.payload)));
  // Perlu diingat, mengakses context di sini lebih kompleks karena ini fungsi top-level.
  // Untuk navigasi kompleks dari background, pertimbangkan untuk menggunakan package seperti go_router
  // atau mengirim data melalui Isolate/Port. Untuk tujuan debugging sederhana, debugPrint cukup.
}
// =========================================================================


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dapurame_channel_id', // ID unik channel notifikasi
      'Notifikasi DapuRame', // Nama channel yang terlihat oleh pengguna
      channelDescription: 'Notifikasi terkait aktivitas DapuRame Anda', // Deskripsi channel
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0, // ID notifikasi (bisa diubah untuk notifikasi berbeda)
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

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
    _initializeNotifications(); // Panggil fungsi inisialisasi
  }

  // Fungsi untuk menginisialisasi notifikasi dan meminta izin (hanya Android)
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Callback ini dipicu saat notifikasi ditekan ketika aplikasi sedang aktif (foreground)
        debugPrint('Foreground Notification tapped: ${notificationResponse.payload}');
      },
      // === UBAH BAGIAN INI ===
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // Panggil fungsi top-level di sini
      // =======================
    );

    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidImplementation?.requestNotificationsPermission();
    if (granted == true) {
      debugPrint('Izin notifikasi Android diberikan.');
    } else {
      debugPrint('Izin notifikasi Android ditolak.');
    }
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
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NotificationPage.showNotification(
            title: 'Notifikasi Tes DapuRame',
            body: 'Ini adalah notifikasi tes dari aplikasi DapuRame!',
          );
        },
        label: const Text('Kirim Notifikasi Tes', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        backgroundColor: Color(0xFF8B4513),
      ),
    );
  }

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