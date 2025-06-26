// lib/edit_profil.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  // Menerima data pengguna saat ini untuk ditampilkan di form
  final Map<String, dynamic> currentUserData;

  const EditProfilePage({super.key, required this.currentUserData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _noHpController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data pengguna saat ini
    _namaController = TextEditingController(
      text: widget.currentUserData['nama'] ?? '',
    );
    _alamatController = TextEditingController(
      text: widget.currentUserData['alamat'] ?? '',
    );
    _noHpController = TextEditingController(
      text: widget.currentUserData['no_hp'] ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menyimpan perubahan ke Firestore
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Gunakan metode 'update' untuk hanya mengubah field yang diperlukan
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'nama': _namaController.text.trim(),
              'alamat': _alamatController.text.trim(),
              'no_hp': _noHpController.text.trim(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman profil setelah menyimpan
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3ED),
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Color(0xFF5A3E2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5A3E2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _namaController,
                labelText: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _alamatController,
                labelText: 'Alamat',
                icon: Icons.home_outlined,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Alamat tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _noHpController,
                labelText: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Nomor HP tidak boleh kosong';
                  if (value.length < 10) return 'Nomor HP terlalu pendek';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89F43),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF5A3E2D)),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF5A3E2D)),
        prefixIcon: Icon(icon, color: const Color(0xFFE89F43)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE89F43), width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
