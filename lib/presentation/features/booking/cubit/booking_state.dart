// lib/presentation/features/booking/cubit/booking_state.dart
import '../../../../data/models/car_model.dart';

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  final String message;
  const BookingSuccess(this.message);
}

class BookingDataLoaded extends BookingState {
  final List<CarModel> cars;
  final List<Map<String, dynamic>> tickets;
  const BookingDataLoaded({required this.cars, required this.tickets});
}

class BookingError extends BookingState {
  final String error;
  const BookingError(this.error);
}