// lib/presentation/features/history/pages/car_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../data/models/car_model.dart';
import '../cubit/car_history_cubit.dart';
import '../cubit/car_history_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarHistoryPage extends StatefulWidget {
  final List<CarModel> cars;
  const CarHistoryPage({super.key, required this.cars});

  @override
  State<CarHistoryPage> createState() => _CarHistoryPageState();
}

class _CarHistoryPageState extends State<CarHistoryPage> {
  CarModel? _activeCar;
  late CarHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = getIt<CarHistoryCubit>();
    if (widget.cars.isNotEmpty) {
      _activeCar = widget.cars.first;
      _historyCubit.getHistoryByCar(_activeCar!.id);
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'processing': return Colors.orange;
      case 'waiting': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyCubit,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          title: const Text('REKAM JEJAK SERVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueGrey.shade900,
          elevation: 0,
        ),
        body: widget.cars.isEmpty
            ? Center(child: Text('Belum ada unit mobil terdaftar', style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD SELECTOR BARIS HORIZONTAL
                  Container(
                    height: 110,
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: widget.cars.length,
                      itemBuilder: (context, index) {
                        final car = widget.cars[index];
                        final bool isSelected = _activeCar?.id == car.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _activeCar = car);
                            _historyCubit.getHistoryByCar(car.id);
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blueGrey.shade900 : Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? Colors.blueGrey.shade900 : Colors.blueGrey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(car.brand, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade300 : Colors.grey.shade600)),
                                const SizedBox(height: 2),
                                Text(car.type, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey.shade800)),
                                const SizedBox(height: 4),
                                Text(car.plate, style: TextStyle(fontSize: 11, fontFamily: 'Courier', fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : Colors.blueGrey.shade600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // TIMELINE LOG TRACK RECORD TIMELINE
                  Expanded(
                    child: BlocBuilder<CarHistoryCubit, CarHistoryState>(
                      builder: (context, state) {
                        if (state is CarHistoryLoading) {
                          return const Center(child: CircularProgressIndicator(color: Colors.blueGrey));
                        }
                        if (state is CarHistoryError) {
                          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Gagal memuat log: ${state.message}', textAlign: TextAlign.center)));
                        }
                        if (state is CarHistoryLoaded) {
                          final tickets = state.tickets;
                          if (tickets.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics_outlined, size: 48, color: Colors.blueGrey.shade200),
                                  const SizedBox(height: 12),
                                  Text('Mobil ini belum memiliki riwayat servis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, fontSize: 13)),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              final String ticketId = ticket['ticketId'] ?? '-';
                              final String tasks = ticket['tasks'] ?? '-';
                              final String status = ticket['status'] ?? 'pending';
                              final int km = ticket['kmCheckIn'] ?? 0;
                              String formattedDate = '-';
                                if (ticket['createdAt'] != null) {
                                  final date = (ticket['createdAt'] as Timestamp).toDate();
                                  formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
                                }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    leading: Container(
                                      width: 4, height: 40,
                                      decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(2)),
                                    ),
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(ticketId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Courier')),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Divider(),
                                            const SizedBox(height: 4),
                                            Text('KILOMETER MASUK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400)),
                                            const SizedBox(height: 2),
                                            Text('${NumberFormat('#,###').format(km)} Km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                                            const SizedBox(height: 12),
                                            Text('DESKRIPSI KERUSAKAN / TUGAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400)),
                                            const SizedBox(height: 2),
                                            Text(tasks, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800, height: 1.4)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}