// lib/presentation/features/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_app/core/constants/asset_paths.dart'; // Import konstanta berkas aset
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog proses memuat data penanda aktivitas sistem sedang berlangsung
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib terkunci aman selama proses asinkronus berjalan
      builder: (context) {
        return PopScope(
          canPop: false, // Menahan tombol kembali fisik Android
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: const Row(
              children: [
                CircularProgressIndicator(color: Colors.blueGrey),
                SizedBox(width: 24),
                Text('Menghubungkan ke server...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onLoginSubmitted() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Jika transisi masuk ke AuthLoading, panggil dialog penanda proses
          if (state is AuthLoading) {
            _showLoadingDialog(context);
          } else {
            // Jika state berubah ke selain loading, tutup dialog memuat secara aman
            if (ModalRoute.of(context)?.isCurrent == false) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }

          if (state is Unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lingkaran Ilustrasi Logo dengan Fallback Gambar bawaan
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: Colors.blueGrey.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            AssetPaths.logoMain,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.blueGrey.shade800,
                                child: const Icon(Icons.directions_car_filled_rounded, size: 52, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Beresin Garasi',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900, // Perbaikan: Menggunakan ketebalan valid murni w900
                        color: Colors.blueGrey.shade900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kelola Perbaikan & Booking Servis Mandiri',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 40),
                    
                    // Input Bidang Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                      decoration: InputDecoration(
                        labelText: 'Alamat Email Anda',
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.blueGrey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Input Bidang Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLoginSubmitted(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Akun',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.blueGrey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.blueGrey),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Kata sandi wajib diisi' : null,
                    ),
                    const SizedBox(height: 36),
                    
                    // Tombol Eksekusi Masuk
                    ElevatedButton(
                      onPressed: _onLoginSubmitted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('MASUK PORTAL PELANGGAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 28),
                    
                    // Tautan Alih Navigasi ke Halaman Registrasi Baru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum bergabung? ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                          child: Text('Buat Akun Baru', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}