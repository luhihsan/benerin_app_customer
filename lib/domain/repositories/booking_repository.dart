// lib/domain/repositories/booking_repository.dart
import '../../data/models/car_model.dart';

abstract class BookingRepository {
  Stream<List<CarModel>> streamCustomerCars(String customerUid);

  /// Pendaftaran mobil baru dengan penambahan parameter spesifikasi mesin dan KM.
  Future<void> addNewCar({
    required String customerUid,
    required String brand,
    required String type,
    required String plate,
    required String year,
    required String color,
    required String engineType,
    required int km,
  });

  Future<void> createBookingTicket({
    required String customerUid,
    required CarModel car,
    required String tasks,
  });

  Stream<List<Map<String, dynamic>>> streamCustomerTickets(String customerUid);
}