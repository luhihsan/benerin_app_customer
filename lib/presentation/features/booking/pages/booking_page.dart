// lib/presentation/features/booking/pages/booking_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  
  // SOLUSI MULTI FOTO: Mengubah penampung foto tunggal menjadi List array dinamis
  final List<File> _selectedImages = []; 
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75, // Kompresi estetik ringan demi menghemat bandwith upload
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path)); // Memasukkan foto baru ke dalam list antrean
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
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.blueGrey),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Mengunggah ${_selectedImages.length} foto & memproses tiket...', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              
              // PERBAIKAN UI: Album Baris Horizontal Mini (Thumbnail Grid View)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DOKUMENTASI FOTO BUKTI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                  Text('${_selectedImages.length} Terpilih', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 96, // Mengunci tinggi container agar kecil dan rapi
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    // Item pertama: Slot tombol "+" untuk memicu kamera/galeri
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _showImageSourceBottomSheet,
                        child: Container(
                          width: 86,
                          margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.blueGrey.shade200, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 20, color: Colors.blueGrey.shade400),
                              const SizedBox(height: 4),
                              const Text('Tambah', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                      );
                    }

                    // Item berikutnya: Card Mini Kotak Preview dari Gambar yang Terpilih
                    final File imageFile = _selectedImages[index - 1];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          margin: const EdgeInsets.only(right: 14, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                            image: DecorationImage(
                              image: FileImage(imageFile),
                              fit: BoxFit.cover, // Gambar terpotong rapi memenuhi aspek kotak 1:1
                            ),
                          ),
                        ),
                        // Tombol Badge Silang Kecil untuk membatalkan/menghapus gambar dari list
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index - 1)),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.7),
                              radius: 11,
                              child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
                      imageFiles: _selectedImages, // Meneruskan seluruh list koleksi foto
                    );
                    if (context.mounted) {
                      Navigator.pop(context); // Tutup Loading Dialog
                      Navigator.pop(context); // Kembali ke Dashboard Navigasi Utama
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Booking multi-foto sukses dibuat! Menunggu konfirmasi admin.'), backgroundColor: Colors.green.shade700),
                      );
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