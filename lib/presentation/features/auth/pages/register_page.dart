// lib/presentation/features/auth/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: const Row(
              children: [
                CircularProgressIndicator(color: Colors.blueGrey),
                SizedBox(width: 24),
                Text('Mendaftarkan akun baru...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// PEMBARUAN: Menampilkan dialog hiasan penanda sukses registrasi berstandar material mewah
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 12),
              const Text('Registrasi Sukses!', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: const Text('Akun garasi Anda telah resmi terdaftar dalam sistem. Silakan masuk menggunakan email dan sandi Anda.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup Dialog Keberhasilan
                Navigator.pop(context); // Lempar pengguna kembali ke halaman utama Login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('MASUK SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: Colors.blueGrey.shade900,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Menutup loading dialog overlay apabila transisi status ber-mutasi aman
          if (state is! AuthLoading) {
            if (ModalRoute.of(context)?.isCurrent == false) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }

          // Menangani skenario penangkapan state sukses pendaftaran
          if (state is RegisterSuccess) {
            _showSuccessDialog(context);
          }

          if (state is Unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red.shade700),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Gabung Beresin Garasi',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  const Text('Daftarkan diri Anda untuk mulai mengelola portofolio kendaraan.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 36),
                  
                  // Bidang Input Nama Pengguna
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Pemilik',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.blueGrey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Bidang Input Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                    decoration: InputDecoration(
                      labelText: 'Alamat Email Aktif',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.blueGrey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Alamat email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Bidang Input WhatsApp Telepon
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                    decoration: InputDecoration(
                      labelText: 'Nomor Kontak WhatsApp',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.blueGrey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nomor kontak wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Bidang Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Proteksi Akun',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.blueGrey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'Kata sandi minimal berisi 6 karakter' : null,
                  ),
                  const SizedBox(height: 36),

                  // Tombol Pemicu Pendaftaran Akun
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showLoadingDialog(context); // Munculkan dialog penanda loading
                        context.read<AuthCubit>().registerCustomer(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          phone: _phoneController.text.trim(),
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
                    child: const Text('SELESAIKAN PENDAFTARAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}