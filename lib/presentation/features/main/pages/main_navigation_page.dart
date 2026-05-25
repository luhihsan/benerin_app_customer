// lib/presentation/features/main/pages/main_navigation_page.dart
import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/asset_paths.dart';
import '../../profile/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _GaragePlaceholderPage(), // Tab 1: Manajemen Banyak Mobil Customer
      const _BookingPlaceholderPage(), // Tab 2: Monitoring Servis Realtime & Booking
      const ProfilePage(),             // Tab 3: Detail Akun & Tombol Keluar
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: Colors.blueGrey.shade100,
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.directions_car_rounded, color: Colors.blueGrey),
            icon: Icon(Icons.directions_car_outlined),
            label: 'Garasi Saya',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.build_circle_rounded, color: Colors.blueGrey),
            icon: Icon(Icons.build_circle_outlined),
            label: 'Servis',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle_rounded, color: Colors.blueGrey),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Tampilan Placeholder Sementara untuk Tab Booking & Live Monitoring Servis
class _BookingPlaceholderPage extends StatelessWidget {
  const _BookingPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('STATUS & BOOKING SERVIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.blueGrey.shade300),
            const SizedBox(height: 16),
            const Text('Belum Ada Penugasan Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Mobil yang Anda booking akan terpantau realtime di sini.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _GaragePlaceholderPage extends StatelessWidget {
  const _GaragePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    // Data dummy simulasi koleksi aset kendaraan banyak mobil milik 1 customer
    final List<Map<String, String>> mockCars = [
      {'brand': 'Honda Civic RS', 'plate': 'AB 1234 EI', 'year': '2022', 'color': 'Sonic Gray'},
      {'brand': 'Toyota Innova Zenix', 'plate': 'AD 9999 GL', 'year': '2024', 'color': 'Platinum White Pearl'},
    ];

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('GARASI SAYA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockCars.length,
        itemBuilder: (context, index) {
          final car = mockCars[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_car_filled_rounded, color: Colors.blueGrey),
              ),
              title: Text(car['brand']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Tahun: ${car['year']} • Warna: ${car['color']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blueGrey.shade900, borderRadius: BorderRadius.circular(8)),
                child: Text(car['plate']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulir penambahan data mobil baru sedang disiapkan')),
          );
        },
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('TAMBAH MOBIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
      ),
    );
  }
}