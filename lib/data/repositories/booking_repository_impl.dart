// lib/data/repositories/booking_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/storage_remote_datasource.dart';
import '../models/car_model.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;
  final StorageRemoteDataSource _storageRemoteDataSource;

  BookingRepositoryImpl(this._firestore, this._storageRemoteDataSource);

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
    required String customerUid, required String brand, required String type,
    required String plate, required String year, required String color,
    required String engineType, required int km,
  }) async {
    await _firestore.collection('cars').add({
      'customerUid': customerUid,
      'brand': brand,
      'type': type,
      'plate': plate,
      'year': year,
      'color': color,
      'engineType': engineType,
      'km': km,
    });
  }

  @override
  Future<void> createBookingTicket({
    required String customerUid,
    required CarModel car,
    required String tasks,
    required List<File> imageFiles,
  }) async {
    List<String> uploadedUrls = [];

    // Jika ada list foto yang dipilih oleh pelanggan, eksekusi upload massal ke ImgBB
    if (imageFiles.isNotEmpty) {
      uploadedUrls = await _storageRemoteDataSource.uploadMultipleComplaintImages(
        imageFiles: imageFiles,
      );
    }

    final String generatedId = 'SRV-${DateTime.now().millisecondsSinceEpoch}';
    
    await _firestore.collection('serviceTickets').add({
      'ticketId': generatedId,
      'customerUid': customerUid,
      'mechanicId': '', 
      'status': 'pending', 
      'tasks': tasks,
      'complaintPhotoUrls': uploadedUrls, // Disimpan sebagai array string berisi sekumpulan URL foto bukti
      'kmCheckIn': car.km,
      'carDetails': {
        'carId': car.id,
        'brand': car.brand,
        'type': car.type,
        'plate': car.plate,
        'year': car.year,
        'color': car.color,
        'engineType': car.engineType,
      },
      'externalProcurements': [], 
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