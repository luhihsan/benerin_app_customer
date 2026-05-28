// lib/presentation/features/history/pages/service_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceTrackingPage extends StatelessWidget {
  final Map<String, dynamic> ticket;
  const ServiceTrackingPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final String ticketId = ticket['ticketId'] ?? '-';
    final String status = ticket['status'] ?? 'pending';
    final String tasks = ticket['tasks'] ?? '-';
    final int km = ticket['kmCheckIn'] ?? 0;
    final Map carData = ticket['carDetails'] ?? {};

    // Menentukan step aktif berdasarkan status dari Firestore
    int currentStep = 0;
    if (status == 'waiting') currentStep = 1;
    if (status == 'processing') currentStep = 2;
    if (status == 'completed') currentStep = 3;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text(ticketId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Courier')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU RINGKASAN UNIT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car_rounded, size: 36, color: Colors.blueGrey.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${carData['brand'] ?? 'Mobil'} ${carData['type'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('No. Polisi: ${carData['plate'] ?? '-'} | $km KM', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('PROGRESS PERBAIKAN UNIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
            const SizedBox(height: 20),

            // TIMELINE TRACKER VERTIKAL
            _buildTrackingStep(
              index: 0,
              currentStep: currentStep,
              title: 'Menerima Permintaan',
              description: 'Tiket berhasil dibuat. Menunggu verifikasi awal dan approval dari Service Advisor bengkel.',
              icon: Icons.assignment_turned_in_rounded,
            ),
            _buildTrackingStep(
              index: 1,
              currentStep: currentStep,
              title: 'Masuk Antrean Bengkel',
              description: 'Tiket disetujui. Kendaraan Anda telah masuk ke dalam daftar antrean antrean urutan pengerjaan bengkel.',
              icon: Icons.hourglass_top_rounded,
            ),
            _buildTrackingStep(
              index: 2,
              currentStep: currentStep,
              title: 'Sedang Dikerjakan Mekanik',
              description: 'Mobil Anda sudah berada di stall servis. Mekanik sedang melakukan perbaikan dan inspeksi menyeluruh.',
              icon: Icons.build_circle_rounded,
              isProcessing: currentStep == 2,
            ),
            _buildTrackingStep(
              index: 3,
              currentStep: currentStep,
              title: 'Selesai & Siap Diambil',
              description: 'Proses perbaikan rampung, unit telah dibersihkan, dan siap diserahterimakan kembali kepada Anda.',
              icon: Icons.check_circle_rounded,
              isLast: true,
            ),
            
            const SizedBox(height: 24),
            // KARTU DESKRIPSI KELUHAN ORIGINAL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueGrey.shade100)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CATATAN KELUHAN AWAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400)),
                  const SizedBox(height: 4),
                  Text(tasks, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep({
    required int index,
    required int currentStep,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
    bool isProcessing = false,
  }) {
    final bool isDone = index < currentStep;
    final bool isCurrent = index == currentStep;

    Color stateColor = Colors.grey.shade400;
    if (isDone) stateColor = Colors.green.shade600;
    if (isCurrent) stateColor = isProcessing ? Colors.blue.shade700 : Colors.orange.shade800;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Garis Jalur & Lingkaran Indikator Node
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrent || isDone ? stateColor.withValues(alpha: 0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: stateColor, width: 2),
              ),
              child: isCurrent && isProcessing
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: stateColor))
                  : Icon(isDone ? Icons.check_rounded : icon, size: 18, color: stateColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 55,
                color: isDone ? Colors.green.shade600 : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Kolom Kanan: Teks Konten Progress Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCurrent || isDone ? Colors.blueGrey.shade900 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: isCurrent ? Colors.blueGrey.shade700 : Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}