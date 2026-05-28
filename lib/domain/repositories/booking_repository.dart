// lib/domain/repositories/booking_repository.dart
import 'dart:io';
import '../../data/models/car_model.dart';

abstract class BookingRepository {
  Stream<List<CarModel>> streamCustomerCars(String customerUid);

  Future<void> addNewCar({
    required String customerUid, required String brand, required String type,
    required String plate, required String year, required String color,
    required String engineType, required int km,
  });

  /// Mengirim pengajuan booking servis baru dengan dukungan banyak foto bukti sekaligus.
  Future<void> createBookingTicket({
    required String customerUid,
    required CarModel car,
    required String tasks,
    required List<File> imageFiles, // Berubah menjadi List koleksi File
  });

  Stream<List<Map<String, dynamic>>> streamCustomerTickets(String customerUid);
}