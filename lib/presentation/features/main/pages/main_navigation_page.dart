// lib/presentation/features/main/pages/main_navigation_page.dart
import 'package:flutter/material.dart';
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
    final brandController = TextEditingController();
    final plateController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DAFTARKAN MOBIL BARU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 16),
                TextFormField(controller: brandController, decoration: const InputDecoration(labelText: 'Merek & Tipe Mobil (e.g. Honda Civic)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                TextFormField(controller: plateController, decoration: const InputDecoration(labelText: 'Nomor Polisi / Plat (e.g. AB 1234 EI)'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: yearController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tahun Rilis'), validator: (v) => v!.isEmpty ? 'Wajib' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: colorController, decoration: const InputDecoration(labelText: 'Warna Unit'), validator: (v) => v!.isEmpty ? 'Wajib' : null)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        cubit.registerNewCar(customerUid: customerUid, brand: brandController.text, plate: plateController.text, year: yearController.text, color: colorController.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('SIMPAN KENDARAAN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
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
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.blueGrey.shade100)),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.directions_car_filled_rounded, color: Colors.white)),
                    title: Text(car.brand, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Warna: ${car.color} • Tahun: ${car.year}', style: const TextStyle(fontSize: 12)),
                    trailing: Chip(label: Text(car.plate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), backgroundColor: Colors.blueGrey.shade900),
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