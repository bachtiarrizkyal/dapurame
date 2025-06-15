import 'package:flutter/material.dart';
import 'package:dapurame/masuk.dart';

class DaftarScreen extends StatefulWidget {
  const DaftarScreen({super.key});

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Definisikan tinggi untuk setiap bagian
    final double topSectionHeight =
        screenHeight * 0.25; // Untuk gambar dan teks atas
    // <<< PERUBAHAN DI SINI >>>
    // Turunkan tinggi gelombang coklat agar kolom di atasnya lebih jelas
    final double bottomWaveHeight =
        screenHeight * 0.3; // Mengurangi dari 0.4 ke 0.3
    // <<< AKHIR PERUBAHAN >>>

    // Tinggi sisa untuk bagian tengah (input fields).
    // Disesuaikan agar input fields dapat dimuat.
    final double middleSectionHeight =
        screenHeight - topSectionHeight - (bottomWaveHeight * 0.8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3ED),
      body: Stack(
        children: [
          // 1. Bagian paling atas: Gambar background, panah kembali, dan teks
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/masuk.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF5A3E2D),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3E2D),
                      ),
                    ),
                    const Text(
                      'Daftar untuk Melanjutkan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Color(0xFF5A3E2D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Bagian tengah: Kolom input (diwrap dengan SingleChildScrollView)
          Positioned(
            top: topSectionHeight,
            left: 0,
            right: 0,
            height: middleSectionHeight,
            child: Container(
              color: const Color(0xFFF8F3ED),
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _namaController,
                      hintText: 'Nama',
                      icon: Icons.person,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _noHpController,
                      hintText: 'No Hp',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _alamatController,
                      hintText: 'Alamat',
                      icon: Icons.location_on,
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Masukkan E-mail Anda',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Masukkan password E-mail Anda',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Masukkan ulang password E-mail Anda',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bagian paling bawah: Gelombang coklat dan tombol-tombolnya
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomWaveHeight, // <<< PERUBAHAN DI SINI >>>
            child: ClipPath(
              clipper: _CustomShapeClipper(),
              child: Container(
                color: const Color(0xFF5A3E2D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint('Tombol Daftar ditekan!');
                          // Lakukan proses pendaftaran di sini
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE89F43),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          debugPrint('Tombol Sudah punya akun ? ditekan!');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MasukScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sudah punya akun ?',
                          style: TextStyle(
                            color: Color(0xFF5A3E2D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF5A3E2D)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 20.0,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFE89F43)),
      ),
    );
  }
}

class _CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0,
      size.width * 0.5,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      0,
      size.height * 0.05,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
