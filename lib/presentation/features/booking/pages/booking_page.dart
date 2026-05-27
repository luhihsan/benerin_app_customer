// lib/presentation/features/booking/pages/booking_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Import package image picker pendukung kamera HP
import '../../../../data/models/car_model.dart';
import '../cubit/booking_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class BookingPage extends StatefulWidget {
  final List<CarModel> cars;
  const BookingPage({super.key, required this.cars});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _tasksController = TextEditingController();
  CarModel? _selectedCar;
  File? _selectedImage; // State penyimpan biner objek gambar bukti keluhan
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cars.isNotEmpty) {
      _selectedCar = widget.cars.first;
    }
  }

  @override
  void dispose() {
    _tasksController.dispose();
    super.dispose();
  }

  /// Membuka dialog pilihan media penangkapan gambar (Kamera atau Galeri smartphone)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Kompresi 80% untuk menghemat kuota upload data Cloud Storage
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: Colors.blueGrey),
              title: const Text('Ambil dari Kamera HP', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.blueGrey),
              title: const Text('Pilih dari Galeri Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Mengunci tombol back native Android
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.blueGrey),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Mengunggah bukti & memproses...', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String customerUid = (authState as Authenticated).user.uid;
    final cubit = context.read<BookingCubit>();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('FORMULIR BOOKING BENGKEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('PILIH UNIT KENDARAAN AKTIF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              DropdownButtonFormField<CarModel>(
                value: _selectedCar,
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: widget.cars.map((car) => DropdownMenuItem(value: car, child: Text('${car.brand} ${car.type} (${car.plate})'))).toList(),
                onChanged: (val) => setState(() => _selectedCar = val),
              ),
              const SizedBox(height: 24),
              const Text('DESKRIPSI KELUHAN & GEJALA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tasksController,
                maxLines: 4,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(hintText: 'Contoh: Rem depan berdecit saat macet, ganti oli mesin.', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi keluhan wajib ditulis' : null,
              ),
              const SizedBox(height: 24),
              
              // FITUR BARU: Komponen Unggah Bukti Visual Foto Keluhan Mobil
              const Text('UNGHAH BUKTI FOTO KELUHAN (OPSIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceBottomSheet,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade200, style: _selectedImage == null ? BorderStyle.solid : BorderStyle.none),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.file(_selectedImage!, width: double.infinity, height: 160, fit: BoxFit.cover),
                              Positioned(
                                top: 8, right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImage = null),
                                  child: CircleAvatar(backgroundColor: Colors.black.withValues(alpha: 0.6), radius: 16, child: const Icon(Icons.close_rounded, size: 18, color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 36, color: Colors.blueGrey.shade300),
                            const SizedBox(height: 8),
                            Text('Tambahkan Foto Bukti Masalah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                            const SizedBox(height: 2),
                            const Text('Membantu mekanik menganalisis kerusakan lebih cepat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedCar != null) {
                    _showLoadingDialog();
                    await cubit.submitServiceBooking(
                      customerUid: customerUid, 
                      car: _selectedCar!, 
                      tasks: _tasksController.text.trim(),
                      imageFile: _selectedImage, // Kirim berkas gambar asli ke BLoC
                    );
                    if (context.mounted) {
                      Navigator.pop(context); // Tutup Loading Dialog
                      Navigator.pop(context); // Kembali ke halaman utama Dashboard Navigasi
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Booking berhasil dikirim! Menunggu approval admin.'), backgroundColor: Colors.green.shade700));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('KIRIM PERMINTAAN SERVIS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}