// lib/domain/repositories/booking_repository.dart
import '../../data/models/car_model.dart';
import '../../data/models/ticket_model.dart'; // Menggunakan basis model tiket terpadu

abstract class BookingRepository {
  /// Mendapatkan aliran data (stream) mobil pribadi milik pelanggan dari Firestore.
  Stream<List<CarModel>> streamCustomerCars(String customerUid);

  /// Mendaftarkan unit mobil baru ke dalam garasi digital pelanggan.
  Future<void> addNewCar({
    required String customerUid,
    required String brand,
    required String plate,
    required String year,
    required String color,
  });

  /// Mengirim pengajuan booking servis baru dengan status awal 'pending'.
  Future<void> createBookingTicket({
    required String customerUid,
    required CarModel car,
    required String tasks,
  });

  /// Memantau sirkulasi status penugasan servis milik pelanggan secara realtime.
  Stream<List<Map<String, dynamic>>> streamCustomerTickets(String customerUid);
}