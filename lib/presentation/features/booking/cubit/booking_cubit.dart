// lib/presentation/features/booking/cubit/booking_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/models/car_model.dart';
import '../../../../domain/repositories/booking_repository.dart';
import 'booking_state.dart';
import 'dart:io';

@injectable
class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;
  StreamSubscription? _dataSubscription;

  BookingCubit(this._repository) : super(const BookingInitial());

  /// Memantau koleksi mobil dan tiket milik customer secara realtime terpadu
  void watchCustomerData(String customerUid) {
    emit(const BookingLoading());
    _dataSubscription?.cancel();

    // Menggabungkan stream mobil dan stream tiket servis untuk konsistensi state
    _dataSubscription = _repository.streamCustomerCars(customerUid).listen((cars) {
      _repository.streamCustomerTickets(customerUid).listen((tickets) {
        emit(BookingDataLoaded(cars: cars, tickets: tickets));
      }, onError: (e) => emit(BookingError(e.toString())));
    }, onError: (e) => emit(BookingError(e.toString())));
  }

  Future<void> registerNewCar({
    required String customerUid,
    required String brand,
    required String type,
    required String plate,
    required String year,
    required String color,
    required String engineType,
    required int km,
  }) async {
    try {
      await _repository.addNewCar(
        customerUid: customerUid,
        brand: brand,
        type: type,
        plate: plate,
        year: year,
        color: color,
        engineType: engineType,
        km: km,
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> submitServiceBooking({
    required String customerUid,
    required CarModel car,
    required String tasks,
    required List<File> imageFiles, 
  }) async {
    try {
      await _repository.createBookingTicket(
        customerUid: customerUid,
        car: car,
        tasks: tasks,
        imageFiles: imageFiles,
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }
}