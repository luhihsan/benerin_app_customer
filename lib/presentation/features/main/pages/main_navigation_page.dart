// lib/presentation/features/main/pages/main_navigation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_app/core/di/injection.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../booking/cubit/booking_cubit.dart';
import '../../booking/cubit/booking_state.dart';
import '../../booking/pages/booking_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../../../data/models/car_model.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final String customerUid = authState.user.uid;

    return BlocProvider<BookingCubit>(
      create: (context) => getIt<BookingCubit>()..watchCustomerData(customerUid),
      child: Scaffold(
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            List<CarModel> userCars = [];
            List<Map<String, dynamic>> userTickets = [];

            if (state is BookingDataLoaded) {
              userCars = state.cars;
              userTickets = state.tickets;
            }

            final List<Widget> pages = [
              _GarageTab(cars: userCars, customerUid: customerUid),
              _ServiceMonitoringTab(tickets: userTickets, cars: userCars),
              const ProfilePage(),
            ];

            return IndexedStack(index: _currentIndex, children: pages);
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          indicatorColor: Colors.blueGrey.shade100,
          backgroundColor: Colors.white,
          elevation: 8,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car_rounded, color: Colors.blueGrey), label: 'Garasi'),
            NavigationDestination(icon: Icon(Icons.build_circle_outlined), selectedIcon: Icon(Icons.build_circle_rounded, color: Colors.blueGrey), label: 'Servis'),
            NavigationDestination(icon: Icon(Icons.account_circle_outlined), selectedIcon: Icon(Icons.account_circle_rounded, color: Colors.blueGrey), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB 1: GARASI SAYA + LEMBAR TAMBAH MOBIL ====================
class _GarageTab extends StatelessWidget {
  final List<CarModel> cars;
  final String customerUid;
  const _GarageTab({required this.cars, required this.customerUid});

  void _openAddCarSheet(BuildContext context, BookingCubit cubit) {
    final typeController = TextEditingController();
    final plateController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final kmController = TextEditingController();
    final customBrandController = TextEditingController(); // Controller tambahan untuk menampung merek kustom
    final formKey = GlobalKey<FormState>();

    // Daftar master merek mobil populer/familiar di Indonesia
    final List<String> brandList = [
      'Toyota', 'Honda', 'Mitsubishi', 'Daihatsu', 'Suzuki', 
      'Nissan', 'Hyundai', 'Wuling', 'Mazda', 'Isuzu', 
      'BMW', 'Mercedes-Benz', 'Other'
    ];

    // Daftar tipe dapur pacu mesin kendaraan
    final List<String> engineTypeList = ['Bensin', 'Diesel', 'Hybrid', 'EV'];

    String? selectedBrand;
    String? selectedEngineType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            top: 24, 
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4, width: 40,
                      decoration: BoxDecoration(color: Colors.blueGrey.shade200, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DAFTARKAN KENDARAAN BARU',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lengkapi data spesifikasi unit demi akurasi perawatan oleh mekanik.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // BARIS 1: Dropdown Pilihan Merek Mobil
                  DropdownButtonFormField<String>(
                    value: selectedBrand,
                    decoration: InputDecoration(
                      labelText: 'Merek Mobil',
                      prefixIcon: const Icon(Icons.apartment_rounded),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: brandList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedBrand = val;
                      });
                    },
                    validator: (v) => v == null ? 'Silakan pilih merek mobil' : null,
                  ),
                  
                  // FITUR BARU: Input Manual Merek Kustom jika memilih 'Other' (Chery, Jaecoo, dll)
                  if (selectedBrand == 'Other') ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('custom_brand_field'), // Mengunci elemen tree agar input connection stabil
                      controller: customBrandController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Masukkan Nama Merek Kustom',
                        hintText: 'Contoh: Chery / Jaecoo',
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (selectedBrand == 'Other' && (v == null || v.trim().isEmpty)) {
                          return 'Nama merek kustom wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 14),

                  // BARIS 2: Input Manual Tipe Mobil
                  TextFormField(
                    key: const ValueKey('car_type_field'),
                    controller: typeController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Tipe / Model Mobil',
                      hintText: 'Contoh: Civic RS / Innova Reborn',
                      prefixIcon: const Icon(Icons.model_training_rounded),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Tipe mobil tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),

                  // BARIS 3: Dropdown Tipe Varian Mesin (Penting untuk perlakuan Diesel vs Bensin vs EV)
                  DropdownButtonFormField<String>(
                    value: selectedEngineType,
                    decoration: InputDecoration(
                      labelText: 'Jenis Bahan Bakar / Mesin',
                      prefixIcon: const Icon(Icons.local_gas_station_rounded),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: engineTypeList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setSheetState(() => selectedEngineType = val),
                    validator: (v) => v == null ? 'Silakan pilih tipe penggerak mesin' : null,
                  ),
                  const SizedBox(height: 14),

                  // BARIS 4: Kombinasi Grid Kiri-Kanan (Plat Nomor & Tahun Rilis)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('plate_field'),
                          controller: plateController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.characters, // Otomatis mengubah input menjadi huruf kapital
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Nomor Polisi',
                            hintText: 'e.g. AB 1234 EI',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('year_field'),
                          controller: yearController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Tahun Rilis',
                            hintText: 'e.g. 2022',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Wajib' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // BARIS 5: Kombinasi Grid Kiri-Kanan (Warna Unit & Angka KM Terbaru)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('color_field'),
                          controller: colorController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Warna Mobil',
                            hintText: 'e.g. Hitam Metalik',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('km_field'),
                          controller: kmController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Penambahan impor material aman
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                          decoration: InputDecoration(
                            labelText: 'KM Aktual Saat Ini',
                            suffixText: 'KM',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (int.tryParse(v) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tombol Utama Eksekusi Simpan Aset
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // SOLUSI KEYBOARD GLITCH: Tutup software keyboard secara native sebelum melakukan submit form data
                        FocusScope.of(sheetContext).unfocus();

                        if (formKey.currentState!.validate() && selectedBrand != null && selectedEngineType != null) {
                          // LOGIKA SELEKSI MEREK: Jika memilih 'Other', ambil string teks manual dari customBrandController
                          final String finalBrand = selectedBrand == 'Other' 
                              ? customBrandController.text.trim() 
                              : selectedBrand!;

                          cubit.registerNewCar(
                            customerUid: customerUid,
                            brand: finalBrand,
                            type: typeController.text.trim(),
                            plate: plateController.text.trim().toUpperCase(),
                            year: yearController.text.trim(),
                            color: colorController.text.trim(),
                            engineType: selectedEngineType!,
                            km: int.tryParse(kmController.text) ?? 0, // Proteksi parsing biner angka murni
                          );

                          Navigator.pop(modalContext); // Menutup sheet dengan aman
                        } else {
                          // Notifikasi jika ada drop-down yang terlewat belum dipilih oleh customer
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Silakan lengkapi seluruh isian data spesifikasi kendaraan terlebih dahulu!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('SIMPAN UNIT KE GARASI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingCubit = context.read<BookingCubit>();
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(title: const Text('GARASI DIGITAL SAYA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), backgroundColor: Colors.white, elevation: 0),
      body: cars.isEmpty
          ? const Center(child: Text('Garasi kosong, silakan daftarkan mobil pertama Anda.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueGrey.shade800, 
                      child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white)
                    ),
                    title: Text('${car.brand} ${car.type}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(car.engineType, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                          ),
                          const SizedBox(width: 8),
                          Text('${car.km} KM • ${car.color}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blueGrey.shade900, borderRadius: BorderRadius.circular(8)),
                      child: Text(car.plate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCarSheet(context, bookingCubit),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('REGISTRASI MOBIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// ==================== TAB 2: LIVE MONITORING REALTIME SERVIS ====================
class _ServiceMonitoringTab extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final List<CarModel> cars;
  const _ServiceMonitoringTab({required this.tickets, required this.cars});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(title: const Text('STATUS PERBAIKAN REALTIME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), backgroundColor: Colors.white, elevation: 0),
      body: tickets.isEmpty
          ? const Center(child: Text('Belum ada riwayat atau aktivitas booking servis.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];
                final status = t['status'] ?? 'pending';
                final carData = t['carDetails'] ?? {};

                Color statusColor = Colors.amber.shade800;
                String statusText = 'MENUNGGU APPROVAL';
                if (status == 'waiting') { statusColor = Colors.orange.shade800; statusText = 'DALAM ANTREAN'; }
                if (status == 'processing') { statusColor = Colors.blue.shade800; statusText = 'SEDANG DIKERJAKAN'; }
                if (status == 'completed') { statusColor = Colors.green.shade700; statusText = 'SELESAI'; }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueGrey.shade100)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t['ticketId'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(carData['brand'] ?? 'Mobil', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Plat Nomor: ${carData['plate'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(height: 24),
                      const Text('KELUHAN / PENGERJAAN:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text(t['tasks'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (cars.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan daftarkan mobil Anda di tab Garasi terlebih dahulu!')));
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (c) => BlocProvider.value(value: context.read<BookingCubit>(), child: BookingPage(cars: cars))));
        },
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.build_rounded),
        label: const Text('BOOKING SERVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}