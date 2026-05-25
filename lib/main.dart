// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_app/core/di/injection.dart';
import 'package:customer_app/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:customer_app/presentation/features/auth/cubit/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Google Services Kredensial JSON
  configureDependencies(); // Menjalankan dependency injection engine
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          // Memeriksa status token sesi login lokal HP secara instan saat boot aplikasi
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'Beresin Garasi - Customer Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              // Placeholder halaman utama jika sesi valid terdeteksi
              return const Scaffold(body: Center(child: Text('MASUK DASHBOARD UTAMA CUSTOMER')));
            }
            if (state is AuthLoading || state is AuthInitial) {
              return const _SplashLoadingView();
            }
            // Mengalihkan rute ke halaman login apabila tidak ada token sesi aktif
            return const Scaffold(body: Center(child: Text('HALAMAN LOGIN UTAMA')));
          },
        ),
      ),
    );
  }
}

/// Tampilan transisi memuat data sesi lokal dengan nuansa warna material gelap premium.
class _SplashLoadingView extends StatelessWidget {
  const _SplashLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.time_to_leave_rounded, // Ikon otomotif penanda gerbang customer
                size: 64,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}