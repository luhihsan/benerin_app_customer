// lib/presentation/features/history/cubit/car_history_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/repositories/booking_repository.dart';
import 'car_history_state.dart';

@injectable
class CarHistoryCubit extends Cubit<CarHistoryState> {
  final BookingRepository _repository;
  StreamSubscription? _ticketsSubscription;

  CarHistoryCubit(this._repository) : super(CarHistoryInitial());

  /// Membuka stream log aktivitas servis berdasarkan carId mobil yang dipilih
  void getHistoryByCar(String carId) {
    emit(CarHistoryLoading());
    _ticketsSubscription?.cancel(); // Batalkan subskripsi stream mobil sebelumnya jika ada

    _ticketsSubscription = _repository.streamTicketsByCar(carId).listen(
      (tickets) {
        emit(CarHistoryLoaded(tickets));
      },
      onError: (error) {
        emit(CarHistoryError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _ticketsSubscription?.cancel();
    return super.close();
  }
}