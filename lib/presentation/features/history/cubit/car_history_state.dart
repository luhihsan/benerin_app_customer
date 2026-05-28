// lib/presentation/features/history/cubit/car_history_state.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class CarHistoryState {}

class CarHistoryInitial extends CarHistoryState {}

class CarHistoryLoading extends CarHistoryState {}

class CarHistoryLoaded extends CarHistoryState {
  final List<Map<String, dynamic>> tickets;
  CarHistoryLoaded(this.tickets);
}

class CarHistoryError extends CarHistoryState {
  final String message;
  CarHistoryError(this.message);
}