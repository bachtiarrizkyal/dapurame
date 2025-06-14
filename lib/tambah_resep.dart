import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'search_bahan.dart';

class TambahResepPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  
  const TambahResepPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<TambahResepPage> createState() => _TambahResepPageState();
}

class _TambahResepPageState extends State<TambahResepPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _waktuJamController = TextEditingController();
  final _waktuMenitController = TextEditingController();
  final _caraMembuatController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _selectedBahan = [];
  bool _isLoading = false;

  bool get isEdit => widget.documentId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit && widget.initialData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final data = widget.initialData!;
    _namaController.text = data['nama'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';
    _caraMembuatController.text = data['cara_membuat'] ?? '';
    
    // Parse waktu masak
    String waktu = data['waktu_masak'] ?? '0 jam 30 menit';
    List<String> parts = waktu.split(' ');
    if (parts.length >= 4) {
      _waktuJamController.text = parts[0];
      _waktuMenitController.text = parts[2];
    }
    
    // Load bahan
    if (data['bahan'] != null) {
      _selectedBahan = List<Map<String, dynamic>>.from(data['bahan']);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Foto Resep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2104),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.camera_alt, color: Color(0xFFE68B2B)),
                      title: const Text('Kamera'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library, color: Color(0xFFE68B2B)),
                      title: const Text('Galeri'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchBahan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchBahanPage(),
      ),
    );
    
    if (result != null) {
      setState(() {
        // Cek apakah bahan sudah ada
        bool exists = _selectedBahan.any((bahan) => bahan['nama'] == result['nama']);
        if (!exists) {
          _selectedBahan.add({
            'nama': result['nama'],
            'jumlah': '1 cup', // Default jumlah
          });
        }
      });
    }
  }

  void _removeBahan(int index) {
    setState(() {
      _selectedBahan.removeAt(index);
    });
  }

  void _editJumlahBahan(int index) {
    TextEditingController jumlahController = TextEditingController(
      text: _selectedBahan[index]['jumlah'],
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Jumlah\n${_selectedBahan[index]['nama']}'),
          content: TextField(
            controller: jumlahController,
            decoration: const InputDecoration(
              hintText: 'Contoh: 2 cup, 500 gram, 1 sdm',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedBahan[index]['jumlah'] = jumlahController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      print('📤 Starting image upload...');
      
      // Check file size
      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      print('📤 File size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
      if (fileSizeInMB > 10) {
        throw Exception('File terlalu besar (max 10MB)');
      }
      
      // Create unique filename
      String fileName = 'resep_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('resep_images')
          .child(fileName);
      
      print('📤 Uploading to: resep_images/$fileName');
      
      // Set metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': 'dapurame_app'},
      );
      
      UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Add progress listener
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📤 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // Set timeout
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Upload timeout!');
          uploadTask.cancel();
          throw Exception('Upload timeout setelah 30 detik');
        },
      );
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      // Jika gagal upload, tetap simpan resep tanpa gambar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Gambar gagal diupload: $e'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
      return null;
    }
  }

  Future<void> _saveResep() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal tambahkan 1 bahan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      
      // Skip image upload for now (Firebase Storage needs billing)
      if (_selectedImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Gambar disimpan lokal (Firebase Storage perlu upgrade)'),
            backgroundColor: Colors.orange,
          ),
        );
        // Store local path as placeholder
        imageUrl = _selectedImage!.path;
      }
      
      String waktuMasak = '${_waktuJamController.text} jam ${_waktuMenitController.text} menit';
      
      Map<String, dynamic> resepData = {
        'nama': _namaController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'waktu_masak': waktuMasak,
        'bahan': _selectedBahan,
        'cara_membuat': _caraMembuatController.text.trim(),
        'rating': 5, // Default rating
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add image URL if available
      if (imageUrl != null) {
        resepData['image_url'] = imageUrl;
      } else if (isEdit && widget.initialData!.containsKey('image_url')) {
        // Keep existing image if editing and no new image selected
        resepData['image_url'] = widget.initialData!['image_url'];
      }

      if (!isEdit) {
        resepData['created_at'] = FieldValue.serverTimestamp();
        resepData['user_id'] = 'current_user'; // TODO: Ganti dengan user ID sebenarnya
      }

      if (isEdit) {
        await FirebaseFirestore.instance
            .collection('resep')
            .doc(widget.documentId)
            .update(resepData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Resep berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('resep')
            .add(resepData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Resep berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan resep: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF662B0E),
        title: Text(
          isEdit ? 'Edit Resep' : 'Tambah Resep',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Foto
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (isEdit && 
                         widget.initialData != null && 
                         widget.initialData!['image_url'] != null &&
                         widget.initialData!['image_url'].toString().startsWith('http'))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.initialData!['image_url'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      Text('Gagal memuat gambar'),
                                    ],
                                  );
                                },
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Color(0xFFE68B2B),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Upload Gambar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A2104),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap untuk pilih foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB7B7B7),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Nama Resep
              const Text(
                'Nama Resep',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A2104),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama resep',
                  hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4A2104)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama resep tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Deskripsi Resep
              const Text(
                'Deskripsi Resep',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A2104),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan deskripsi resep',
                  hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4A2104)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Lama Memasak
              const Text(
                'Lama Memasak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A2104),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waktuJamController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
                        suffixText: 'jam',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF4A2104)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jam tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _waktuMenitController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
                        suffixText: 'menit',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF4A2104)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Menit tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bahan-Bahan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bahan - Bahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A2104),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _searchBahan,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Bahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE68B2B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // List Bahan
              if (_selectedBahan.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Color(0xFFB7B7B7),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada bahan ditambahkan',
                        style: TextStyle(
                          color: Color(0xFFB7B7B7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _selectedBahan.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> bahan = entry.value;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE68B2B)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              bahan['nama'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4A2104),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _editJumlahBahan(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEACC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  bahan['jumlah'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4A2104),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeBahan(index),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 16),
              
              // Cara Membuat
              const Text(
                'Cara Membuat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A2104),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caraMembuatController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Masukkan langkah-langkah memasak...',
                  hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE68B2B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4A2104)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cara membuat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),
              
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveResep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE68B2B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menyimpan...'),
                          ],
                        )
                      : Text(
                          isEdit ? 'Update Resep' : 'Simpan Resep',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _waktuJamController.dispose();
    _waktuMenitController.dispose();
    _caraMembuatController.dispose();
    super.dispose();
  }
}