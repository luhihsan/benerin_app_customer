// lib/presentation/features/booking/pages/booking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.blueGrey),
            SizedBox(width: 24),
            Text('Memproses tiket booking...', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
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
                items: widget.cars.map((car) => DropdownMenuItem(value: car, child: Text('${car.brand} (${car.plate})'))).toList(),
                onChanged: (val) => setState(() => _selectedCar = val),
              ),
              const SizedBox(height: 24),
              const Text('DESKRIPSI KELUHAN & GEJALA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tasksController,
                maxLines: 5,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(hintText: 'Contoh: Rem depan bunyi berdecit saat macet, sekalian ganti oli mesin.', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi keluhan wajib ditulis' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedCar != null) {
                    _showLoadingDialog();
                    await cubit.submitServiceBooking(customerUid: customerUid, car: _selectedCar!, tasks: _tasksController.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context); // Tutup Loading Dialog
                      Navigator.pop(context); // Kembali ke halaman utama Dashboard
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Booking berhasil dibuat! Menunggu konfirmasi admin.'), backgroundColor: Colors.green.shade700));
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