// lib/data/repositories/booking_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/car_model.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepositoryImpl(this._firestore);

  @override
  Stream<List<CarModel>> streamCustomerCars(String customerUid) {
    return _firestore
        .collection('cars')
        .where('customerUid', isEqualTo: customerUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CarModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> addNewCar({
    required String customerUid,
    required String brand,
    required String plate,
    required String year,
    required String color,
  }) async {
    await _firestore.collection('cars').add({
      'customerUid': customerUid,
      'brand': brand,
      'plate': plate,
      'year': year,
      'color': color,
    });
  }

  @override
  Future<void> createBookingTicket({
    required String customerUid,
    required CarModel car,
    required String tasks,
  }) async {
    final String generatedId = 'SRV-${DateTime.now().millisecondsSinceEpoch}';
    
    await _firestore.collection('serviceTickets').add({
      'ticketId': generatedId,
      'customerUid': customerUid,
      'mechanicId': '', // Kosong di awal, akan diisi oleh web admin owner bengkel
      'status': 'pending', // Status 'pending' penanda menunggu approval jadwal admin
      'tasks': tasks,
      'kmCheckIn': 0,
      'carDetails': {
        'carId': car.id,
        'brand': car.brand,
        'plate': car.plate,
        'year': car.year,
        'color': car.color,
      },
      'externalProcurements': [], // Array kosong siap diisi nota suku cadang murni oleh mekanik
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCustomerTickets(String customerUid) {
    return _firestore
        .collection('serviceTickets')
        .where('customerUid', isEqualTo: customerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['documentId'] = doc.id;
              return data;
            }).toList());
  }
}